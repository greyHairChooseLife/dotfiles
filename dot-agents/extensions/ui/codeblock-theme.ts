import { readFileSync, readdirSync, realpathSync } from "node:fs";
import { dirname, join } from "node:path";
import { homedir } from "node:os";
import { pathToFileURL } from "node:url";

const DEFAULT_CODE_BG = "#232330";
const DEFAULT_LANG_COLOR = "#7ec8e3";
const DEFAULT_INLINE_FG = "#78b888";
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
    // Theme schema rejects unknown keys under `colors`, so these two custom
    // values live under `vars` (which allows arbitrary names). Fall back to
    // `colors` for older theme files.
    const vars = raw.vars || {};
    const colors = raw.colors || raw;
    const codeBgValue = vars.codeBlockBg ?? colors.mdCodeBlockBg;
    const langValue = vars.codeBlockLang ?? colors.mdCodeBlockLang;
    return {
      codeBg: HEX_COLOR.test(codeBgValue) ? codeBgValue : DEFAULT_CODE_BG,
      langColor: HEX_COLOR.test(langValue) ? langValue : DEFAULT_LANG_COLOR,
      inlineFg: resolveColor(colors.mdCode, vars) ?? DEFAULT_INLINE_FG,
    };
  } catch {
    return { codeBg: DEFAULT_CODE_BG, langColor: DEFAULT_LANG_COLOR, inlineFg: DEFAULT_INLINE_FG };
  }
}

// `colors.mdCode` is either a hex literal or the name of a `vars` entry.
function resolveColor(value: unknown, vars: Record<string, unknown>): string | undefined {
  if (typeof value !== "string") return undefined;
  if (HEX_COLOR.test(value)) return value;
  const fromVars = vars[value];
  return typeof fromVars === "string" && HEX_COLOR.test(fromVars) ? fromVars : undefined;
}

function stripAnsi(s: string): string {
  return s.replace(/\x1b\[[0-9;]*[a-zA-Z]/g, "").replace(/\x1b\][^\x07]*\x07/g, "");
}

// Background SGR sequences: 40-47 (basic), 100-107 (bright), 48 (extended),
// 49 (default background). The user-message renderer paints one across every line.
const BG_SEQ = /\x1b\[(?:4[0-7]|10[0-7]|49|48;[0-9;]*)m/g;
function stripBg(s: string): string {
  return s.replace(BG_SEQ, "");
}

// Background the surrounding renderer painted at the start of the line (user
// messages). Used to keep the padX margins matching the message background.
const LEADING_BG = /^\x1b\[(?:4[0-7]|10[0-7]|48;[0-9;]*)m/;
function leadingBg(s: string): string {
  return LEADING_BG.exec(s)?.[0] ?? "";
}

function leadingSpaces(line: string): number {
  const match = /^ +/.exec(line);
  return match ? match[0].length : 0;
}

// ── Inline code colour ────────────────────────────────────
//
// pi-tui renders `codespan` through `theme.fg("mdCode", text)`, i.e. a plain
// foreground span. The line filter can only see escapes, so rebuild both forms
// the renderer can emit (truecolor and 256-colour approximation).

const CUBE = [0, 95, 135, 175, 215, 255];
const GRAY = Array.from({ length: 24 }, (_v, index) => 8 + index * 10);

function closestIndex(values: number[], target: number): number {
  let best = 0;
  for (let index = 1; index < values.length; index++) {
    if (Math.abs(target - values[index]) < Math.abs(target - values[best])) best = index;
  }
  return best;
}

function ansi256Of(r: number, g: number, b: number): number {
  const ri = closestIndex(CUBE, r);
  const gi = closestIndex(CUBE, g);
  const bi = closestIndex(CUBE, b);
  const distance = (c: { r: number; g: number; b: number }) =>
    (r - c.r) ** 2 * 0.299 + (g - c.g) ** 2 * 0.587 + (b - c.b) ** 2 * 0.114;
  const grayIndex = closestIndex(GRAY, Math.round(0.299 * r + 0.587 * g + 0.114 * b));
  const gray = GRAY[grayIndex];
  const cube = { r: CUBE[ri], g: CUBE[gi], b: CUBE[bi] };
  if (Math.max(r, g, b) - Math.min(r, g, b) < 10 && distance({ r: gray, g: gray, b: gray }) < distance(cube)) {
    return 232 + grayIndex;
  }
  return 16 + 36 * ri + 6 * gi + bi;
}

// Span = mdCode foreground escape, text, then the `\x1b[39m` reset theme.fg adds.
function inlineCodePattern(hex: string): RegExp {
  const [r, g, b] = [1, 3, 5].map(i => parseInt(hex.slice(i, i + 2), 16));
  const truecolor = `\\x1b\\[38;2;${r};${g};${b}m`;
  const indexed = `\\x1b\\[38;5;${ansi256Of(r, g, b)}m`;
  return new RegExp(`(?:${truecolor}|${indexed})(?:.*?)\\x1b\\[39m`, "g");
}

// ── Locate the Markdown class the CLI really renders with ──
//
// The CLI entry (dist/bundle/cli.js) loads compiled chunks. pi-tui is inlined
// into them, and the bundle re-exports `Markdown` from the chunk that defines
// it. Import that same chunk (ESM cache → same module instance) and patch
// `Markdown.prototype.render` directly. No tree-walking or adoption heuristics.

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
        if (typeof mod?.Markdown?.prototype?.render === "function") return mod;
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
  const Markdown = live?.Markdown;
  if (typeof Markdown?.prototype?.render !== "function") {
    console.error("[codeblock-theme] Could not reach the running Markdown class. Extension disabled.");
    return;
  }

  const { codeBg, langColor, inlineFg } = readThemeConfig();
  const INLINE_CODE = inlineCodePattern(inlineFg);
  const BG = hexToAnsiBg(codeBg);        // background fill
  const FG_HIDE = hexToAnsiFg(codeBg);   // foreground = background → invisible backticks
  const FG_LANG = hexToAnsiFg(langColor); // accent color for the language badge
  const RESET_BG = "\x1b[49m";
  const RESET_FG = "\x1b[39m";
  const INLINE_PAD = " ";

  let visibleWidth: (s: string) => number = (s) => Array.from(stripAnsi(s)).length;
  try {
    const utils: any = await import(pathToFileURL(TUI_UTILS).href);
    if (typeof utils?.visibleWidth === "function") visibleWidth = utils.visibleWidth;
  } catch {
    // Keep the local fallback.
  }

  // ── Line builders ───────────────────────────────────────

  // The padX margins must show the background already active on the line (the
  // user-message background). The code background is re-asserted after its own
  // RESET_BG so the right margin keeps that background too.
  function wrapMargins(inner: string, padX: number, outerBg: string): string {
    const margin = " ".repeat(padX);
    if (!outerBg) return margin + inner + margin;
    return outerBg + margin + inner + outerBg + margin + RESET_BG;
  }

  // Space before and after the span text, inside the background.
  function padInlineSpan(span: string): string {
    return span.replace(/^(\x1b\[[0-9;]*m)([\s\S]*?)(\x1b\[39m)$/, `$1${INLINE_PAD}$2${INLINE_PAD}$3`);
  }

  // The padding adds visible cells. Reclaim them from the filler spaces the
  // renderer appended, so the line still occupies exactly `width` cells. Falls
  // back to undefined when the line has no filler left to give up.
  function fitToWidth(line: string, width: number): string | undefined {
    const excess = visibleWidth(line) - width;
    if (excess <= 0) return line;
    const tail = /( +)((?:\x1b\[[0-9;]*m)*)$/.exec(line);
    if (!tail || tail[1].length < excess) return undefined;
    return line.slice(0, tail.index) + tail[1].slice(excess) + tail[2];
  }

  function buildFenceLine(padX: number, contentW: number, lang: string, outerBg: string): string {
    // Backticks stay hidden; the language badge is right-aligned with a small inset.
    const label = "```";
    const inset = 1;
    const name = lang.slice(0, Math.max(0, contentW - label.length - inset));
    const gap = " ".repeat(Math.max(0, contentW - label.length - name.length - (name ? inset : 0)));
    const pad = name ? " ".repeat(inset) : "";
    const badge = name ? FG_LANG + name + RESET_FG : "";
    const inner = BG + FG_HIDE + label + RESET_FG + gap + badge + pad + RESET_BG;
    return wrapMargins(inner, padX, outerBg);
  }

  function buildCodeLine(line: string, padX: number, contentW: number): string {
    // User-message lines are wrapped in a `userMessageBg` background escape, so
    // the left margin is not at character 0. Drop the background (it would
    // cover the code background) and any leading SGR, then split at the margin.
    const outerBg = leadingBg(line);
    const stripped = stripBg(line);
    const leadEsc = /^(?:\x1b\[[0-9;]*m)*/.exec(stripped)?.[0] ?? "";
    const rest = stripped.slice(leadEsc.length);
    const lead = Math.min(padX, leadingSpaces(rest));
    const body = rest.slice(lead).replace(/ +$/, "");
    const fill = " ".repeat(Math.max(0, contentW - visibleWidth(body)));
    return wrapMargins(BG + body + fill + RESET_BG, padX, outerBg);
  }

  function withCodeBlockBackground(lines: string[], padX: number, width: number): string[] {
    const contentW = Math.max(1, width - padX * 2);
    const out: string[] = [];
    let inBlock = false;

    for (const line of lines) {
      // Strip color/bg escapes before measuring the margin: a user-message line
      // starts with a background escape, not with its leading spaces. Detect the
      // fence after all leading whitespace, so fences nested in a list item
      // (indented past padX) are found too.
      const plain = stripAnsi(line);
      const body = plain.slice(leadingSpaces(plain));
      const isFence = body.startsWith("```") || body.startsWith("~~~");

      if (isFence && !inBlock) {
        inBlock = true;
        out.push(buildFenceLine(padX, contentW, body.slice(3).trim(), leadingBg(line)));
      } else if (isFence && inBlock) {
        inBlock = false;
        out.push(buildFenceLine(padX, contentW, "", leadingBg(line)));
      } else if (inBlock) {
        out.push(buildCodeLine(line, padX, contentW));
      } else {
        // Inline code: paint the span, pad it, and restore the background the
        // line already had (user messages carry one) after its own reset.
        const outerBg = leadingBg(line);
        const paint = (span: string, padded: boolean) =>
          BG + (padded ? padInlineSpan(span) : span) + RESET_BG + outerBg;
        const padded = fitToWidth(line.replace(INLINE_CODE, (span) => paint(span, true)), width);
        out.push(padded ?? line.replace(INLINE_CODE, (span) => paint(span, false)));
      }
    }

    return out;
  }

  // ── Patch the Markdown prototype ────────────────────────

  // Guard against a second extension load wrapping the render twice.
  const PATCHED = Symbol.for("pi.codeblock-theme.patched");
  if ((Markdown.prototype as any)[PATCHED]) return;
  (Markdown.prototype as any)[PATCHED] = true;

  const origRender = Markdown.prototype.render;
  Markdown.prototype.render = function (this: any, width: number): string[] {
    const rendered: string[] = origRender.call(this, width);
    try {
      return withCodeBlockBackground(rendered, this.paddingX ?? 1, width);
    } catch {
      return rendered;
    }
  };
}
