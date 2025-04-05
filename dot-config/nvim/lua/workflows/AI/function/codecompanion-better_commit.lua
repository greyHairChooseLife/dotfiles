local function generate_commit_message()
	local handle_staged = io.popen("git --no-pager diff --no-ext-diff --staged")
	local handle_unstaged = io.popen("git --no-pager diff")
	local handle_untracked = io.popen("git --no-pager ls-files --others --exclude-standard")

	if handle_staged == nil and handle_staged == nil and handle_untracked == nil then
		return nil
	end

	local staged = ""
	local unstaged = ""
	local untracked = ""
	if handle_staged ~= nil then
		staged = handle_staged:read("*a")
		handle_staged:close()
	end
	if handle_unstaged ~= nil then
		unstaged = handle_unstaged:read("*a")
		handle_unstaged:close()
	end
	if handle_untracked ~= nil then
		untracked = handle_untracked:read("*a")
		handle_untracked:close()
	end

	local content = [[
You are a commit assistant.

- Objective
  Analyze the current Git status and diffs to determine whether the currently staged changes form a clean, single-purpose commit.

- Instructions
  1. If there are staged changes then evaluate the staging:
     - Are the currently staged changes appropriate for a single commit?
     - Is anything missing or excessive?
  2. If not appropriate or nothings staged at all:
     - List the changes using `-` bullets for clarity, and recommend how to split them into logical commits.
     - Recommand some git commands for better staging like `git add`or `git add --patch` or `git reset --soft` or etc.
  3. If appropriate:
     - Generate a commit message following the `commitizen` convention.

- Commit message style
  - Title: concise, imperative English, under 50 characters
  - Body: Korean, 72-character line width
  - Use `-` bullet points
  - Avoid full sentences, use concise phrases

- Output
  - In case of commit message, provide the message inside a ```gitcommit code block.
  - In case of explaination for better staging, format is important and should look like:
```markdown
> [!WARNING]
> brief one line of explaination
>
> (only if need)entire and brief explanation.

1. (in English)feat: something
   - (in Korean)change 1
   - (in Korean)change 2

   _recommand_
   `git add --patch <somefile> # startLN:endLN, startLN:endLN`

2. fix: something
   - change 1
   - change 2

   _recommand_
   `git add <somefile>`
   `git reset --soft <somefile>`
```


### Git-Status-Summary

]]
	if #staged > 0 then
		content = content
			.. "== Staged Changes Start(`git diff --no-ext-diff --staged`) ==\n```diff\n"
			.. staged
			.. "\n```\n== Staged Changes End(`git diff --no-ext-diff --staged`) ==\n\n"
	end
	if #unstaged > 0 then
		content = content
			.. "== Unstaged Changes Start(`git diff`) ==\n```diff\n"
			.. unstaged
			.. "\n```\n== Unstaged Changes End(`git diff`) ==\n\n"
	end
	if #untracked > 0 then
		content = content
			.. "== Untracked Files(`git ls-files --others --exclude-standard`) ==\n```plaintext\n"
			.. untracked
			.. "\n```\n\n"
		local untracked_files = vim.split(untracked, "\n")
		for _, file in ipairs(untracked_files) do
			if file ~= "" then
				local cmd = "git diff --no-index /dev/null " .. file
				local s = vim.fn.system(cmd)
				if s ~= "" then
					content = content
						.. "== Diff For Untracked File "
						.. file
						.. " Start (`"
						.. cmd
						.. "`) ==\n```diff\n"
					content = content
						.. s
						.. "\n```\n== Diff For Untracked File "
						.. file
						.. " End (`"
						.. cmd
						.. "`) ==\n\n"
				end
			end
		end
	end

	return content
end

---@param chat CodeCompanion.Chat
local function callback(chat)
	local content = generate_commit_message()
	if content == nil then
		vim.notify("No git diff available", vim.log.levels.INFO, { title = "CodeCompanion" })
		return
	end
	chat:add_buf_message({
		role = "user",
		content = content,
	})
end

return {
	description = "Generate git commit message",
	callback = callback,
	opts = {
		adapter = {
			name = "copilot",
			model = "claude-3.5-sonnet",
		},
		contains_code = true,
	},
}
