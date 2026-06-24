import { AssistantMessageComponent } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

const DEFAULT_CODE_BG = "#232330";
const DEFAULT_LANG_COLOR = "#7ec8e3";

// ── Helpers ───────────────────────────────────────────────

function hexToAnsiBg(hex: string) {
  const [r, g, b] = [1, 3, 5].map(i => parseInt(hex.slice(i, i + 2), 16));
  return `\x1b[48;2;${r};${g};${b}m`;
}
function hexToAnsiFg(hex: string) {
  const [r, g, b] = [1, 3, 5].map(i => parseInt(hex.slice(i, i + 2), 16));
  return `\x1b[38;2;${r};${g};${b}m`;
}

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

interface Section { type: "text" | "code"; text?: string; lang?: string; code?: string }

function splitSections(mdText: string): Section[] {
  const s: Section[] = [];
  const re = /```(\w*)\n([\s\S]*?)```/g;
  let last = 0, m: RegExpExecArray | null;
  while ((m = re.exec(mdText)) !== null) {
    if (m.index > last) s.push({ type: "text", text: mdText.slice(last, m.index) });
    s.push({ type: "code", lang: m[1] || "", code: m[2] });
    last = m.index + m[0].length;
  }
  if (last < mdText.length) s.push({ type: "text", text: mdText.slice(last) });
  return s;
}

// ── Main ──────────────────────────────────────────────────

export default async function () {
  const PI_TUI = "/usr/lib/node_modules/pi/node_modules/@earendil-works/pi-tui/dist/index.js";
  const THEME_MOD = "/usr/lib/node_modules/pi/packages/coding-agent/dist/modes/interactive/theme/theme.js";

  // ── Import dependencies (fail gracefully if paths change) ──
  let Box: any, Markdown: any, getMarkdownTheme: any;
  try {
    ({ Box, Markdown } = await import(PI_TUI));
    ({ getMarkdownTheme } = await import(THEME_MOD));
  } catch (err) {
    console.error("[codeblock-theme] Import failed — pi may have updated. Extension disabled.", (err as Error).message);
    return;
  }

  const { codeBg, langColor } = readThemeConfig();
  const LANG_FG = hexToAnsiFg(langColor);
  const BG_ANSI = hexToAnsiBg(codeBg);
  const bgFn = (t: string) => BG_ANSI + t + "\x1b[49m";

  // ── Try to patch; if anything throws, silently degrade ──
  try {
    const origUpdate = AssistantMessageComponent.prototype.updateContent;

    AssistantMessageComponent.prototype.updateContent = function (message: any) {
      // Always run the original first — never break core rendering
      origUpdate.call(this, message);

      // Post-process to wrap code blocks in background Boxes
      try {
        patchCodeBlocks(this, message, getMarkdownTheme, Box, Markdown, bgFn, LANG_FG, splitSections);
      } catch {
        // Silently degrade: code blocks render without custom styling
      }
    };
  } catch (err) {
    console.error("[codeblock-theme] Patch failed — extension disabled.", (err as Error).message);
  }
}

function patchCodeBlocks(
  self: any,
  _message: any,
  getMarkdownTheme: any,
  Box: any,
  Markdown: any,
  bgFn: (t: string) => string,
  LANG_FG: string,
  splitSections: (text: string) => Section[],
) {
  const mkTheme = getMarkdownTheme();
  const container = self.contentContainer;
  if (!container || !container.children) return;

  const oldKids = [...container.children] as any[];
  const newKids: any[] = [];

  for (const kid of oldKids) {
    if (!(kid instanceof Markdown)) { newKids.push(kid); continue; }

    const kidText = (kid as any).text as string | undefined;
    if (!kidText || !kidText.includes("```")) { newKids.push(kid); continue; }

    const sections = splitSections(kidText);
    if (sections.length <= 1) { newKids.push(kid); continue; }

    for (const sec of sections) {
      if (sec.type === "code") {
        const box = new Box(1, 0, bgFn);
        const lang = sec.lang || "";

        const md = new Markdown("```" + lang + "\n" + sec.code + "```", 0, 0, mkTheme);

        if (lang) {
          // Right-aligned language badge
          const badge = LANG_FG + lang + "\x1b[39m";
          box.addChild({
            render: (w: number) => [" ".repeat(Math.max(0, w - lang.length)) + badge],
            invalidate: () => {},
          } as any);
        }

        box.addChild(md);
        newKids.push(box);
      } else if (sec.text && sec.text.trim()) {
        newKids.push(new Markdown(sec.text, 1, 0, mkTheme));
      }
    }
  }

  container.clear();
  for (const k of newKids) container.addChild(k);
}
