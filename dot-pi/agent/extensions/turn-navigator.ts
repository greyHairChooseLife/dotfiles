/**
 * Turn Navigator Extension
 *
 * Navigate between user messages (conversation turns) with keyboard shortcuts:
 *   alt+k  — Focus previous turn (copy full query to clipboard)
 *   alt+j  — Focus next turn (copy full query to clipboard)
 *
 * Shows the focused message preview in a widget above the editor.
 * The widget disappears when at the latest turn.
 */

import { copyToClipboard } from "@earendil-works/pi-coding-agent";
import type { ExtensionAPI, ExtensionContext, SessionMessageEntry } from "@earendil-works/pi-coding-agent";

/** Information about one user message in the current conversation. */
interface UserMessageInfo {
  entryId: string;
  text: string;
}

function getUserMessageText(entry: SessionMessageEntry): string {
  const content = entry.message.content;
  if (typeof content === "string") return content;
  return content
    .filter((c): c is { type: "text"; text: string } => c.type === "text")
    .map((c) => c.text)
    .join(" ")
    .trim();
}

function isUserMessageEntry(entry: unknown): entry is SessionMessageEntry {
  return (
    typeof entry === "object" &&
    entry !== null &&
    (entry as Record<string, unknown>).type === "message" &&
    (entry as Record<string, unknown>).message !== undefined &&
    (entry as Record<string, unknown>).message !== null &&
    typeof (entry as Record<string, unknown>).message === "object" &&
    (entry as { message: { role: string } }).message.role === "user"
  );
}

function collectUserMessages(ctx: ExtensionContext): UserMessageInfo[] {
  const entries = ctx.sessionManager.getBranch();
  // getBranch already returns entries in chronological order (oldest first).
  const messages: UserMessageInfo[] = [];
  for (const entry of entries) {
    if (!isUserMessageEntry(entry)) continue;
    const text = getUserMessageText(entry);
    if (!text) continue;
    messages.push({ entryId: entry.id, text });
  }
  return messages;
}

export default function (pi: ExtensionAPI) {
  let userMessages: UserMessageInfo[] = [];
  let currentIndex = -1; // -1 = "unfocused" / at latest turn
  let widgetTimer: ReturnType<typeof setTimeout> | undefined;

  const WIDGET_ID = "turn-nav";
  const WIDGET_DISPLAY_MS = 2000;

  // ---------- helpers ----------

  function rebuildUserMessages(ctx: ExtensionContext): void {
    userMessages = collectUserMessages(ctx);
    if (currentIndex >= userMessages.length) {
      currentIndex = userMessages.length - 1;
    } else if (currentIndex < 0 && userMessages.length > 0) {
      currentIndex = userMessages.length - 1;
    }
  }

  function showWidget(ctx: ExtensionContext): void {
    if (ctx.mode !== "tui" || !ctx.hasUI) return;

    if (userMessages.length === 0) return;

    const idx = currentIndex >= 0 ? currentIndex : userMessages.length - 1;
    const turn = userMessages[idx];
    const total = userMessages.length;
    const theme = ctx.ui.theme;

    const position = theme.fg("dim", `Turn ${idx + 1}/${total}`);
    const raw = turn.text.replace(/\s+/g, " ");
    const truncated = raw.length > 100 ? raw.slice(0, 97) + "..." : raw;
    const preview = theme.fg("accent", truncated);

    ctx.ui.setWidget(WIDGET_ID, [
      `  ${position}  ${preview}`,
    ], { placement: "aboveEditor" });

    // Schedule auto-clear after 2s
    if (widgetTimer) clearTimeout(widgetTimer);
    widgetTimer = setTimeout(() => {
      ctx.ui.setWidget(WIDGET_ID, undefined);
      widgetTimer = undefined;
    }, WIDGET_DISPLAY_MS);
  }

  function clearWidget(ctx: ExtensionContext): void {
    if (widgetTimer) {
      clearTimeout(widgetTimer);
      widgetTimer = undefined;
    }
    if (ctx.mode !== "tui" || !ctx.hasUI) return;
    ctx.ui.setWidget(WIDGET_ID, undefined);
  }

  function goToTurn(direction: -1 | 1, ctx: ExtensionContext): void {
    rebuildUserMessages(ctx);
    if (userMessages.length === 0) return;

    if (currentIndex < 0) {
      if (direction === -1) {
        // "Previous turn" from latest
        currentIndex = userMessages.length - 2;
        if (currentIndex < 0) {
          currentIndex = 0;
          return; // silently stay at boundary
        }
      } else {
        return; // already at latest, silently no-op
      }
    } else {
      currentIndex += direction;
    }

    // Silently clamp at boundaries
    if (currentIndex < 0) {
      currentIndex = 0;
      return;
    }
    if (currentIndex >= userMessages.length) {
      currentIndex = userMessages.length - 1;
      return;
    }

    // Copy the full query to clipboard
    const turn = userMessages[currentIndex];
    copyToClipboard(turn.text).catch(() => {
      // clipboard failure is non-critical, ignore
    });

    showWidget(ctx);
  }

  // ---------- events ----------

  pi.on("session_start", async (_event, ctx) => {
    rebuildUserMessages(ctx);
  });

  pi.on("turn_end", async (_event, ctx) => {
    rebuildUserMessages(ctx);
    // Widget auto-clears via timeout, no need to re-render
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    clearWidget(ctx);
  });

  // ---------- shortcuts ----------

  pi.registerShortcut("alt+k", {
    description: "Focus previous turn (copy query)",
    handler: (ctx) => goToTurn(-1, ctx),
  });

  pi.registerShortcut("alt+j", {
    description: "Focus next turn (copy query)",
    handler: (ctx) => goToTurn(1, ctx),
  });
}
