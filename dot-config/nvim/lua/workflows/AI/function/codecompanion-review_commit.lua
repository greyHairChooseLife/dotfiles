local function generate_review_message()
	local handle_diff = io.popen("git --no-pager log -p HEAD^..HEAD")

	if handle_diff == nil then
		return nil
	end

	local diff = ""
	if handle_diff ~= nil then
		diff = handle_diff:read("*a")
		handle_diff:close()
	end

	local content = [[
Please read the provided Git diff and write a concise technical report in Korean, following the structure below. Respond only in Korean.

Structure:
- Title: One-line summary
- Summary of Changes
- Description of Functional or Behavioral Impact
- Examples in a format of 'as-is, to-be'",

### Git-diff

]]
	if #diff > 0 then
		content = content
			.. "== Diff Start(`git --no-pager log -p HEAD^..HEAD`) ==\n```diff\n"
			.. diff
			.. "\n```\n== Diff End(`git --no-pager log -p HEAD^..HEAD`) ==\n\n"
	end

	return content
end

---@param chat CodeCompanion.Chat
local function callback(chat)
	local content = generate_review_message()
	if content == nil then
		vim.notify("No git diff available", vim.log.levels.INFO, { title = "CodeCompanion" })
		return
	end
	chat:add_buf_message({
		role = "user",
		content = content,
	})
end

-- return {
-- 	description = "ReviewCommit",
-- 	callback = callback,
-- 	opts = {
-- 		contains_code = true,
-- 		short_name = "wtf",
-- 	},
-- }

local fmt = string.format

local constants = {
	LLM_ROLE = "llm",
	USER_ROLE = "user",
	SYSTEM_ROLE = "system",
}
return {
	strategy = "chat",
	description = "Explain the LSP diagnostics for the selected code",
	opts = {
		index = 9,
		is_default = true,
		is_slash_cmd = false,
		modes = { "v" },
		short_name = "wtf",
		auto_submit = true,
		user_prompt = false,
		stop_context_insertion = true,
	},
	prompts = {
		{
			role = constants.SYSTEM_ROLE,
			content = [[You are an expert coder and helpful assistant who can help debug code diagnostics, such as warning and error messages. When appropriate, give solutions with code snippets as fenced codeblocks with a language identifier to enable syntax highlighting.]],
			opts = {
				visible = false,
			},
		},
		{
			role = constants.USER_ROLE,
			content = function(context)
				local diagnostics = require("codecompanion.helpers.actions").get_diagnostics(
					context.start_line,
					context.end_line,
					context.bufnr
				)

				local concatenated_diagnostics = ""
				for i, diagnostic in ipairs(diagnostics) do
					concatenated_diagnostics = concatenated_diagnostics
						.. i
						.. ". Issue "
						.. i
						.. "\n  - Location: Line "
						.. diagnostic.line_number
						.. "\n  - Buffer: "
						.. context.bufnr
						.. "\n  - Severity: "
						.. diagnostic.severity
						.. "\n  - Message: "
						.. diagnostic.message
						.. "\n"
				end

				return fmt(
					[[The programming language is %s. This is a list of the diagnostic messages:

%s
]],
					context.filetype,
					concatenated_diagnostics
				)
			end,
		},
		{
			role = constants.USER_ROLE,
			content = function(context)
				local code = require("codecompanion.helpers.actions").get_code(
					context.start_line,
					context.end_line,
					{ show_line_numbers = true }
				)
				return fmt(
					[[
This is the code, for context:

```%s
%s
```
]],
					context.filetype,
					code
				)
			end,
			opts = {
				contains_code = true,
			},
		},
	},
}
