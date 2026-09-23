import { readFileSync, readdirSync, realpathSync } from "node:fs";
import { dirname, join } from "node:path";
import { homedir } from "node:os";
import { pathToFileURL } from "node:url";

const DEFAULT_CODE_BG = "#232330";
const DEFAULT_LANG_COLOR = "#7ec8e3";
const BUNDLE_ENTRY = "/usr/lib/node_modules/pi/packages/coding-agent/dist/bundle/cli.js";
const TUI_UTILS = "/usr/lib/node_modules/pi/node_modules/@earendil-works/pi-tui/dist/utils.js";
const HEX_COLOR = /^#[0-9a-fA-F]{6}$/;

// ── Helpers ───────────────────────────────────────────────

function hexToAnsi(prefix: string, hex: string) {
  const [r, g, b] = [1, 3, 5].map(i => parseInt(hex.slice(i, i + 2), 16));
  return `\x1b[${prefix};2;${r};${g};${b}m`;
}
const hexToAnsiBg = (h: string) => hexToAnsi("48", h);
const hexToAnsiFg = (h: string) => hexToAnsi("38", h);

function readThemeConfig() {
  try {
    const p = join(homedir(), ".pi", "agent", "themes", "ember-glow.json");
    const raw = JSON.parse(readFileSync(p, "utf-8"));
    const colors = raw.colors || raw;
    return {
      codeBg: HEX_COLOR.test(colors.mdCodeBlockBg) ? colors.mdCodeBlockBg : DEFAULT_CODE_BG,
      langColor: HEX_COLOR.test(colors.mdCodeBlockLang) ? colors.mdCodeBlockLang : DEFAULT_LANG_COLOR,
    };
  } catch {
    return { codeBg: DEFAULT_CODE_BG, langColor: DEFAULT_LANG_COLOR };
  }
}

function stripAnsi(s: string): string {
  return s.replace(/\x1b\[[0-9;]*[a-zA-Z]/g, "").replace(/\x1b\][^\x07]*\x07/g, "");
}

function leadingSpaces(line: string): number {
  const match = /^ +/.exec(line);
  return match ? match[0].length : 0;
}

// ── Locate the Markdown class the CLI really renders with ──
//
// The CLI entry (dist/bundle/cli.js) loads compiled chunks. pi-tui is inlined
// into them: `Markdown=class{...}` lives in chunk-*.js but is NOT re-exported.
// So the class cannot be imported directly, and the standalone
// @earendil-works/pi-tui copy is a different class object.
//
// The live `Container` IS exported. Patch its render() and adopt the prototype
// of the first Markdown child it renders.

function bundleDirs(): string[] {
  const dirs: string[] = [];
  try {
    const entry = realpathSync(process.argv[1]);
    if (entry.endsWith("cli.js")) dirs.push(dirname(entry));
  } catch {
    // Not launched from a bundle entry — fall through to the known install path.
  }
  try {
    dirs.push(dirname(realpathSync(BUNDLE_ENTRY)));
  } catch {
    // Install path missing.
  }
  return [...new Set(dirs)];
}

function chunkPaths(bundleDir: string): string[] {
  const paths: string[] = [];
  // Chunks the CLI itself imports, in load order.
  try {
    const runtime = readFileSync(join(bundleDir, "cli-runtime.js"), "utf-8");
    for (const match of runtime.matchAll(/from"\.\/(chunks\/[^"]+\.js)"/g)) {
      paths.push(join(bundleDir, match[1]));
    }
  } catch {
    // Runtime file missing.
  }
  // Safety net: any other chunk that defines the class inline.
  try {
    const chunksDir = join(bundleDir, "chunks");
    for (const file of readdirSync(chunksDir)) {
      if (!file.startsWith("chunk-") || !file.endsWith(".js")) continue;
      const path = join(chunksDir, file);
      if (paths.includes(path)) continue;
      try {
        if (readFileSync(path, "utf-8").includes("Markdown=class{")) paths.push(path);
      } catch {
        // Unreadable chunk.
      }
    }
  } catch {
    // Chunks directory missing.
  }
  return paths;
}

async function loadLiveBundle(): Promise<any | undefined> {
  // Importing a chunk the CLI already loaded hits the ESM cache: same module
  // instance, no re-execution.
  for (const dir of bundleDirs()) {
    for (const chunk of chunkPaths(dir)) {
      try {
        const mod: any = await import(pathToFileURL(chunk).href);
        if (typeof mod?.Container?.prototype?.render === "function") return mod;
      } catch {
        // Try the next candidate.
      }
    }
  }
  return undefined;
}

// ── Code block background ─────────────────────────────────

export default async function () {
  const live = await loadLiveBundle();
  const Container = live?.Container;
  if (typeof Container?.prototype?.render !== "function") {
    console.error("[codeblock-theme] Could not reach the running Markdown class. Extension disabled.");
    return;
  }

  const { codeBg, langColor } = readThemeConfig();
  const BG = hexToAnsiBg(codeBg);        // background fill
  const FG_HIDE = hexToAnsiFg(codeBg);   // foreground = background → invisible backticks
  const FG_LANG = hexToAnsiFg(langColor); // accent color for the language badge
  const RESET_BG = "\x1b[49m";
  const RESET_FG = "\x1b[39m";

  let visibleWidth: (s: string) => number = (s) => Array.from(stripAnsi(s)).length;
  try {
    const utils: any = await import(pathToFileURL(TUI_UTILS).href);
    if (typeof utils?.visibleWidth === "function") visibleWidth = utils.visibleWidth;
  } catch {
    // Keep the local fallback.
  }

  // ── Line builders ───────────────────────────────────────

  function buildFenceLine(padX: number, contentW: number, lang: string): string {
    // Backticks stay hidden; the language badge is right-aligned with a small inset.
    const label = "```";
    const inset = 1;
    const name = lang.slice(0, Math.max(0, contentW - label.length - inset));
    const gap = " ".repeat(Math.max(0, contentW - label.length - name.length - (name ? inset : 0)));
    const pad = name ? " ".repeat(inset) : "";
    const badge = name ? FG_LANG + name + RESET_FG : "";
    return " ".repeat(padX) + BG + FG_HIDE + label + RESET_FG + gap + badge + pad + RESET_BG + " ".repeat(padX);
  }

  function buildCodeLine(line: string, padX: number, contentW: number): string {
    // Drop the renderer's trailing padding, then split at the left margin.
    // The margin is plain spaces, so slicing by character is column-safe here.
    const body = line.replace(/ +$/, "").slice(padX);
    const fill = " ".repeat(Math.max(0, contentW - visibleWidth(body)));
    return " ".repeat(padX) + BG + body + fill + RESET_BG + " ".repeat(padX);
  }

  function withCodeBlockBackground(lines: string[], padX: number, width: number): string[] {
    const contentW = Math.max(1, width - padX * 2);
    const out: string[] = [];
    let inBlock = false;

    for (const line of lines) {
      const lead = Math.min(padX, leadingSpaces(line));
      const body = stripAnsi(line).slice(lead);
      const isFence = body.startsWith("```") || body.startsWith("~~~");

      if (isFence && !inBlock) {
        inBlock = true;
        out.push(buildFenceLine(padX, contentW, body.slice(3).trim()));
      } else if (isFence && inBlock) {
        inBlock = false;
        out.push(buildFenceLine(padX, contentW, ""));
      } else if (inBlock) {
        out.push(buildCodeLine(line, padX, contentW));
      } else {
        out.push(line);
      }
    }

    return out;
  }

  // ── Patch the adopted prototype ─────────────────────────

  let markdownProto: any;
  let shapeMismatch = false;

  function patchMarkdown(proto: any) {
    if (markdownProto) return;
    const origRender = proto.render;
    proto.render = function (this: any, width: number): string[] {
      const rendered: string[] = origRender.call(this, width);
      try {
        return withCodeBlockBackground(rendered, this.paddingX ?? 1, width);
      } catch {
        return rendered;
      }
    };
    markdownProto = proto;
  }

  function isMarkdown(component: any): boolean {
    return typeof component?.renderToken === "function"
      && typeof component?.render === "function"
      && typeof component?.paddingX === "number"
      && typeof component?.theme?.codeBlockBorder === "function";
  }

  function looksLikeMarkdown(component: any): boolean {
    return typeof component?.renderToken === "function"
      || String(component?.constructor?.name ?? "").includes("Markdown");
  }

  function adoptMarkdown(node: any, seen: Set<any>): boolean {
    if (markdownProto) return true;
    if (!node || seen.size > 2000 || seen.has(node)) return false;
    seen.add(node);
    const children = node.children;
    if (!Array.isArray(children)) return false;
    for (const child of children) {
      if (isMarkdown(child)) {
        patchMarkdown(Object.getPrototypeOf(child));
        return true;
      }
      if (!shapeMismatch && looksLikeMarkdown(child)) shapeMismatch = true;
      if (adoptMarkdown(child, seen)) return true;
    }
    return false;
  }

  // Adoption walks the tree, so rate-limit it before the first hit. Markdown
  // only appears once a message, changelog, or help panel is rendered — that
  // can be long after startup, so there is no deadline here.
  let lastAdoptAttempt = 0;

  const origContainerRender = Container.prototype.render;
  Container.prototype.render = function (this: any, width: number): string[] {
    if (!markdownProto && Date.now() - lastAdoptAttempt > 100) {
      lastAdoptAttempt = Date.now();
      try {
        adoptMarkdown(this, new Set());
      } catch {
        // Never let adoption break rendering.
      }
    }
    return origContainerRender.call(this, width);
  };

  // Report only a real breakage: a Markdown component exists but its shape no
  // longer matches (usually after a pi update).
  const warnTimer = setTimeout(() => {
    if (!markdownProto && shapeMismatch) {
      console.error("[codeblock-theme] Markdown component shape changed (pi update?). Code block background disabled.");
    }
  }, 10000);
  warnTimer.unref?.();
}
