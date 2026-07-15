import { readFileSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

const DEFAULT_CODE_BG = "#232330";
const DEFAULT_LANG_COLOR = "#7ec8e3";

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
      codeBg: colors.mdCodeBlockBg ?? DEFAULT_CODE_BG,
      langColor: colors.mdCodeBlockLang ?? DEFAULT_LANG_COLOR,
    };
  } catch {
    return { codeBg: DEFAULT_CODE_BG, langColor: DEFAULT_LANG_COLOR };
  }
}

function stripAnsi(s: string): string {
  return s.replace(/\x1b\[[0-9;]*[a-zA-Z]/g, "").replace(/\x1b\][^\x07]*\x07/g, "");
}

// ── Main ──────────────────────────────────────────────────

export default async function () {
  const PI_TUI = "/usr/lib/node_modules/pi/node_modules/@earendil-works/pi-tui/dist/index.js";

  let Markdown: any;
  try {
    ({ Markdown } = await import(PI_TUI));
  } catch (err) {
    console.error("[codeblock-theme] Import failed — pi may have updated. Extension disabled.", (err as Error).message);
    return;
  }

  const { codeBg, langColor } = readThemeConfig();
  const BG = hexToAnsiBg(codeBg);            // background fill
  const FG_HIDE = hexToAnsiFg(codeBg);       // foreground = background  → invisible backticks
  const FG_LANG = hexToAnsiFg(langColor);    // accent color for language badge
  const RESET_BG = "\x1b[49m";
  const RESET_FG = "\x1b[39m";

  // ── Patch Markdown.render ───────────────────────────────
  try {
    const origRender = Markdown.prototype.render;

    Markdown.prototype.render = function (width: number): string[] {
      const rendered: string[] = origRender.call(this, width);
      const padX = (this as any).paddingX ?? 1;
      const contentW = Math.max(1, width - padX * 2);

      const out: string[] = [];
      let inBlock = false;

      for (const line of rendered) {
        const plain = stripAnsi(line).trimStart();

        // Detect fence: ``` or ~~~ at start of visible text
        const isFence = plain.startsWith("```") || plain.startsWith("~~~");

        if (isFence && !inBlock) {
          inBlock = true;
          const lang = plain.slice(3).trim();
          out.push(buildOpenFence(padX, contentW, lang));
        } else if (isFence && inBlock) {
          inBlock = false;
          out.push(buildCloseFence(padX, contentW));
        } else if (inBlock) {
          // Code content line — keep 1-char margins outside the background
          const left = line.slice(0, padX);
          const middle = line.slice(padX, line.length - padX);
          const right = line.slice(line.length - padX);
          out.push(left + BG + middle + RESET_BG + right);
        } else {
          out.push(line);
        }
      }

      return out;
    };
  } catch (err) {
    console.error("[codeblock-theme] Patch failed — extension disabled.", (err as Error).message);
  }

  // ── Fence builders (closure over BG, FG_HIDE, FG_LANG) ──

  function buildOpenFence(padX: number, contentW: number, lang: string): string {
    const badge = lang ? FG_LANG + lang + RESET_FG : "";
    const badgeLen = lang.length;
    const gap = Math.max(0, contentW - 3 - badgeLen);

    const inner = FG_HIDE + "```" + RESET_FG + " ".repeat(gap) + badge;
    return " ".repeat(padX) + BG + inner + RESET_BG + " ".repeat(padX);
  }

  function buildCloseFence(padX: number, contentW: number): string {
    const gap = Math.max(0, contentW - 3);
    const inner = FG_HIDE + "```" + RESET_FG + " ".repeat(gap);
    return " ".repeat(padX) + BG + inner + RESET_BG + " ".repeat(padX);
  }
}
