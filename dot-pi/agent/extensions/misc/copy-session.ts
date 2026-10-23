import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawn, execSync } from "node:child_process";

// --- clipboard (async, non-blocking) ---

const STATUS_ID = "copy-session";

function platformCopy(text: string): void {
  const p = process.platform;
  let bin: string;
  let args: string[];

  if (p === "darwin") {
    bin = "pbcopy";
    args = [];
  } else if (p === "linux") {
    try {
      execSync("which wl-copy", { stdio: "ignore" });
      bin = "wl-copy";
      args = [];
    } catch {
      bin = "xclip";
      args = ["-selection", "clipboard"];
    }
  } else if (p === "win32") {
    bin = "clip";
    args = [];
  } else {
    return;
  }

  const child = spawn(bin, args, { stdio: "pipe", detached: true });
  child.stdin.write(text);
  child.stdin.end();
  child.unref();
}

function clearStatus(ctx: any): void {
  try { ctx.ui.setStatus(STATUS_ID, ""); } catch {}
}

// --- toggle state ---

let withCwd = false;

export default function (pi: ExtensionAPI) {
  pi.registerShortcut("alt+s", {
    description: "Copy session-id (or cwd + session-id). Alternates each press.",
    handler: async (ctx) => {
      const id = ctx.sessionManager.getSessionId();
      if (!id) {
        ctx.ui.notify("No active session", "error");
        return;
      }

      const text = withCwd ? `${ctx.cwd} ${id}` : id;
      withCwd = !withCwd;

      platformCopy(text);

      clearStatus(ctx);
      const theme = ctx.ui.theme;
      ctx.ui.setStatus(STATUS_ID, theme.fg("accent", `Copied: ${text}`));
      setTimeout(() => clearStatus(ctx), 2000);
    },
  });
}
