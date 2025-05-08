local user_role_content = [[### Instructions

You are required to read files and return all list and contents. Each of them should be inclosed within codeblock with each of filetype.

For example,

### list of files
- file1
- file2

### contents of files

- filepath
  ```json
  ```
- filepath
  ```typescript.
  ```

Target files are changed list of last reviewed commit.

For example, if you reviewed <commit_hash>, get me **BOTH** list and file's contents with commands below:
- for list: `git diff --name-only <commit_hash>^..<commit_hash>`
- for file contents:
`git diff --name-only <commit_hash>^..<commit_hash> | xargs -I {} sh -c 'echo ===== {}; git show <commit_hash>^:{}'`


Use the @cmd_runner tool.
]]

return {
	strategy = "chat",
	description = "Get full files for references that are related git status.",
	opts = {
		is_default = true, -- don't show on action palette
		is_slash_cmd = true,
		short_name = "load full file contents for analyzing commit",
		auto_submit = true,
		user_prompt = false,
		ignore_system_prompt = true,
		stop_context_insertion = true,
		adapter = {
			name = "copilot",
			model = "claude-3.5-sonnet",
		},
	},
	prompts = {
		{
			role = "user",
			opts = { contains_code = true },
			content = function()
				-- Enable turbo mode!!!
				vim.g.codecompanion_auto_tool_mode = true

				return user_role_content
			end,
		},
	},
}
