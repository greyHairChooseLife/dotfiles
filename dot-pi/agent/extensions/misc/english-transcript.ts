/**
 * English Transcript on Quit
 *
 * On quit, writes the session transcript (user + assistant turns) to
 * ~/.local/state/english/transcripts/YYYY-MM-DD.jsonl, one line per session.
 *
 * This extension does no model call. A model call during shutdown takes seconds and is lost
 * when the process is killed by a closed pane or window, which is how most sessions end.
 * A local file append survives that path, so the analysis happens later, in `english-brief`.
 *
 * Disable with PI_ENGLISH_TRANSCRIPT=off.
 */

import { appendFileSync, mkdirSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const TRANSCRIPT_DIR = join(homedir(), ".local", "state", "english", "transcripts");
const MIN_USER_TURNS = 3;
const MAX_TRANSCRIPT_CHARS = 20_000;
const ENGLISH_RATIO = 0.9;

type ContentBlock = {
	type?: string;
	text?: string;
	name?: string;
};

type SessionEntry = {
	type?: string;
	message?: {
		role?: string;
		content?: unknown;
	};
};

type TranscriptMessage = {
	role: "user" | "assistant";
	text: string;
	tools?: string[];
};

const textOf = (content: unknown): string => {
	if (typeof content === "string") {
		return content.trim();
	}
	if (!Array.isArray(content)) {
		return "";
	}

	const parts: string[] = [];
	for (const block of content) {
		if (!block || typeof block !== "object") {
			continue;
		}
		const part = block as ContentBlock;
		if (part.type === "text" && typeof part.text === "string") {
			parts.push(part.text);
		}
	}
	return parts.join("\n").trim();
};

const toolNamesOf = (content: unknown): string[] => {
	if (!Array.isArray(content)) {
		return [];
	}

	const names: string[] = [];
	for (const block of content) {
		if (!block || typeof block !== "object") {
			continue;
		}
		const part = block as ContentBlock;
		if (part.type === "toolCall" && typeof part.name === "string") {
			names.push(part.name);
		}
	}
	return names;
};

const isEnglish = (text: string): boolean => {
	if (!text) {
		return false;
	}
	let ascii = 0;
	for (let i = 0; i < text.length; i++) {
		if (text.charCodeAt(i) < 128) {
			ascii++;
		}
	}
	return ascii / text.length >= ENGLISH_RATIO;
};

const localDate = (): string => {
	const now = new Date();
	const month = String(now.getMonth() + 1).padStart(2, "0");
	const day = String(now.getDate()).padStart(2, "0");
	return `${now.getFullYear()}-${month}-${day}`;
};

/**
 * Rebuild the conversation as messages, newest first while budgeting, so a long session keeps
 * the most relevant tail. Tool payloads are replaced by a name marker.
 */
const buildMessages = (entries: SessionEntry[]): { messages: TranscriptMessage[]; englishUserTurns: number } => {
	const collected: TranscriptMessage[] = [];
	let englishUserTurns = 0;
	let used = 0;

	for (let i = entries.length - 1; i >= 0; i--) {
		const entry = entries[i];
		if (entry.type !== "message" || !entry.message?.role) {
			continue;
		}

		const role = entry.message.role;
		if (role !== "user" && role !== "assistant") {
			continue;
		}

		const text = textOf(entry.message.content);
		if (!text) {
			continue;
		}

		if (role === "user" && isEnglish(text)) {
			englishUserTurns++;
		}
		if (used + text.length > MAX_TRANSCRIPT_CHARS) {
			break;
		}
		used += text.length;

		const message: TranscriptMessage = { role, text };
		if (role === "assistant") {
			const tools = toolNamesOf(entry.message.content);
			if (tools.length > 0) {
				message.tools = tools;
			}
		}
		collected.unshift(message);
	}

	return { messages: collected, englishUserTurns };
};

/**
 * Synchronous on purpose: the process is already being torn down when this runs, and an
 * awaited write was observed to be dropped on the pane-close path.
 */
const appendRecord = (fileName: string, record: Record<string, unknown>): void => {
	mkdirSync(TRANSCRIPT_DIR, { recursive: true });
	appendFileSync(join(TRANSCRIPT_DIR, fileName), `${JSON.stringify(record)}\n`, "utf8");
};

export default function (pi: ExtensionAPI) {
	pi.on("session_shutdown", async (event, ctx) => {
		if (process.env.PI_ENGLISH_TRANSCRIPT === "off") {
			return;
		}

		const { messages, englishUserTurns } = buildMessages(
			ctx.sessionManager.buildContextEntries() as SessionEntry[],
		);
		if (englishUserTurns < MIN_USER_TURNS) {
			return;
		}

		try {
			appendRecord(`${localDate()}.jsonl`, {
				// seconds, matching lookups.jsonl
				ts: Math.floor(Date.now() / 1000),
				shutdown: event.reason,
				session: ctx.sessionManager.getSessionId(),
				file: ctx.sessionManager.getSessionFile() ?? null,
				cwd: ctx.sessionManager.getCwd(),
				model: ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : null,
				englishUserTurns,
				messages,
			});
		} catch (error) {
			const message = error instanceof Error ? error.message : String(error);
			try {
				appendRecord("errors.jsonl", {
					ts: Math.floor(Date.now() / 1000),
					session: ctx.sessionManager.getSessionId(),
					error: message,
				});
			} catch {
				// nothing left to do
			}
		}
	});
}
