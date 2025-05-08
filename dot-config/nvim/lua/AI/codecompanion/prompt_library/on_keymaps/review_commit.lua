-- REF:: context
--  {
--    bufnr = 7,
--    buftype = "",
--    filename = "/home/sy/dotfiles/dot-config/tmux/tmux.conf",
--    filetype = "lua",
--    is_normal = false,
--    is_visual = true,
--    mode = "v",
--    start_line = 8,
--    end_line = 10,
--    line_count = 3,
--    start_col = 1,
--    end_col = 3,
--    cursor_pos = { 10, 3 },
--    lines = { "content of line 8", 'content of line 9', "end" },
--    winnr = 1000
--  }

local system_role_content = [[
Instruction: Please read the provided Git log with diff. Then write a concise technical report in Korean, following the structure below. Respond only in Korean.

Output:
> commit_hash_short
> **One-line summary**
### Summary of Changes
### Description of Functional or Behavioral Impact
### Examples in a format of 'as-is, to-be'

Warning: Never use markdown headers `#`, `##`. Only use others like `###`, `####`, `#####`, `######`.

Notice: Before you answer, if full of related files contents might be needed for enough understanding, don't hesitate to request.
]]

return {
	strategy = "chat",
	description = "",
	opts = {
		modes = { "n", "v" },
		is_default = true, -- don't show on action palette
		is_slash_cmd = false,
		short_name = "review_commit",
		auto_submit = true,
		user_prompt = false,
		ignore_system_prompt = true,
		stop_context_insertion = true,
		adapter = {
			-- name = "anthropic",
			-- model = "claude-3-7-sonnet-20250219", -- think
			-- model = "claude-3-5-sonnet-20241022", -- thinkless
			name = "copilot",
			model = "claude-3.7-sonnet",
		},
	},
	prompts = {
		{
			role = "system",
			opts = { visible = false },
			content = system_role_content,
		},
		{
			role = "user",
			opts = { contains_code = true },
			content = function(context)
				local commit_hash = context.is_visual and context.lines[1] or "HEAD"

				local log_cmd = "git --no-pager log --no-ext-diff --format='%H%nAuthor: %an <%ae>%nDate: %ad%n%n    %s%n%n    %b' "
					.. commit_hash
					.. "^.."
					.. commit_hash
				local log_output = vim.fn.system(log_cmd)
				local log_block = "```gitcommit\n" .. log_output .. "```"

				local diff_cmd = "git --no-pager diff --no-ext-diff " .. commit_hash .. "^.." .. commit_hash
				local diff_output = vim.fn.system(diff_cmd)
				local diff_block = "```diff\n" .. diff_output .. "```"

				return "### Here is git log (`"
					.. log_cmd
					.. "`)\n"
					.. log_block
					.. "\n\n### Here is git diff (`"
					.. diff_cmd
					.. "`)\n"
					.. diff_block
					.. "\n\n"
			end,
		},
	},
}
