/**
 * Turn Navigator Extension
 *
 * Navigate between user messages (conversation turns) with keyboard shortcuts:
 *   alt+k  — Focus previous turn (copy full query to clipboard)
 *   alt+j  — Focus next turn (copy full query to clipboard)
 *
 * Shows the focused message preview in the footer (clears after 2s).
 * Disappears when at the latest turn.
 */

import { copyToClipboard } from "@earendil-works/pi-coding-agent";
import type { ExtensionAPI, ExtensionContext, SessionMessageEntry } from "@earendil-works/pi-coding-agent";

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
  const messages: UserMessageInfo[] = [];
  for (const entry of entries) {
    if (!isUserMessageEntry(entry)) continue;
    const text = getUserMessageText(entry);
    if (!text) continue;
    messages.push({ entryId: entry.id, text });
  }
  return messages;
}

// ---

const STATUS_ID = "turn-nav";

export default function (pi: ExtensionAPI) {
  let userMessages: UserMessageInfo[] = [];
  let currentIndex = -1; // -1 = at latest turn (unfocused)
  let statusTimer: ReturnType<typeof setTimeout> | undefined;

  function rebuild(ctx: ExtensionContext): void {
    userMessages = collectUserMessages(ctx);
    if (currentIndex >= userMessages.length) {
      currentIndex = userMessages.length - 1;
    } else if (currentIndex < 0 && userMessages.length > 0) {
      currentIndex = userMessages.length - 1;
    }
  }

  function clearStatus(ctx: ExtensionContext): void {
    if (statusTimer) {
      clearTimeout(statusTimer);
      statusTimer = undefined;
    }
    ctx.ui.setStatus(STATUS_ID, "");
  }

  function showStatus(ctx: ExtensionContext, text: string): void {
    clearStatus(ctx);

    // Truncate long queries for the footer
    const oneLine = text.replace(/\s+/g, " ");
    const truncated = oneLine.length > 80 ? oneLine.slice(0, 77) + "..." : oneLine;

    const theme = ctx.ui.theme;
    ctx.ui.setStatus(STATUS_ID, theme.fg("accent", truncated));

    statusTimer = setTimeout(() => clearStatus(ctx), 2000);
  }

  function goToTurn(direction: -1 | 1, ctx: ExtensionContext): void {
    rebuild(ctx);
    if (userMessages.length === 0) return;

    if (currentIndex < 0) {
      if (direction === -1) {
        currentIndex = userMessages.length - 2;
        if (currentIndex < 0) {
          currentIndex = 0;
          return;
        }
      } else {
        return;
      }
    } else {
      currentIndex += direction;
    }

    if (currentIndex < 0) {
      currentIndex = 0;
      return;
    }
    if (currentIndex >= userMessages.length) {
      // back to latest → clear
      currentIndex = userMessages.length - 1;
      clearStatus(ctx);
      return;
    }

    const turn = userMessages[currentIndex];
    const total = userMessages.length;
    const label = `Turn ${currentIndex + 1}/${total}: ${turn.text}`;

    copyToClipboard(turn.text).catch(() => {});
    showStatus(ctx, label);
  }

  // ---------- events ----------

  pi.on("session_start", async (_event, ctx) => rebuild(ctx));
  pi.on("turn_end", async (_event, ctx) => rebuild(ctx));
  pi.on("session_shutdown", async (_event, ctx) => clearStatus(ctx));

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
