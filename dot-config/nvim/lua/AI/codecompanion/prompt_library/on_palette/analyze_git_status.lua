local system_role_content = [[
You are a commit assistant.

- Objective
  Analyze the current Git status and diffs to determine whether the currently staged changes form a clean, single-purpose commit.

- Instructions
  1. If there are staged changes then evaluate the staging:
     - Are the currently staged changes appropriate for a single commit?
     - Is anything missing or excessive?
     - Some changes may be incomplete and not suitable for inclusion in a finalized commit. In such cases, it's preferable to leave them out and commit them later when complete.
  2. If not appropriate or nothings staged at all:
     - List the changes using `-` bullets for clarity, and recommend how to split them into logical commits.
     - Recommand some git commands for better staging like `git add`or `git add --patch` or `git reset --soft` or etc.

     > [!NOTE]
     > Incomplete changes should be left out of the commit and held for later
     > - Examples: unfinished functions, unused variables, missing test coverage, etc.
     > - These changes are best committed once their purpose and completion are clear

  3. If appropriate:
     - Generate a commit message following the `commitizen` convention.

- Commit message style
  - Title: concise, imperative English, under 50 characters
  - Body: Korean, 72-character line width
  - Avoid full sentences, use concise phrases
  - Use `-` bullet points and don't make empty line between those bullet points.

- Output
  - In case of commit message, provide the message inside a ```gitcommit code block.
  - In case of explaination for better staging, format is important and should look like:
````markdown
> [!WARNING]
> brief one line of explaination
>
> (only if need)entire and brief explanation.

1. (in English)feat: something
   - (in Korean)change 1
   - (in Korean)change 2

   _recommand_
   `git add <somefile>`

2. fix: something
   - change 1
   - change 2

   _recommand_
   `git add <somefile>`
   `git reset --soft <somefile>`
````
]]

return {
	strategy = "chat",
	description = "suggest separated staging after analyzing git status",
	opts = {
		is_slash_cmd = false,
		-- modes = { "v" },
		short_name = "analyze_git_status_for_commits",
		auto_submit = false,
		user_prompt = false,
		ignore_system_prompt = true,
		stop_context_insertion = true,
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
			content = function()
				local chage_model = require("AI.codecompanion.utils.general").chage_model
				-- MEMO:: github copilot is not unlimited anymore
				-- chage_model("gemini-2.5-pro")

				local handle_staged = io.popen("git --no-pager diff --no-ext-diff --staged")
				local handle_unstaged = io.popen("git --no-pager diff")
				local handle_untracked = io.popen("git --no-pager ls-files --others --exclude-standard")

				if handle_staged == nil and handle_unstaged == nil and handle_untracked == nil then
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

				local git_status = "### Git-Status-Summary\n\n"

				if #staged > 0 then
					git_status = git_status
						.. "#### Staged Changes Start(`git diff --no-ext-diff --staged`)\n````diff\n"
						.. staged
						.. "````\n\n"
				end
				if #unstaged > 0 then
					git_status = git_status
						.. "#### Unstaged Changes Start(`git diff`)\n````diff\n"
						.. unstaged
						.. "````\n\n"
				end
				if #untracked > 0 then
					git_status = git_status
						.. "#### Untracked Files(`git ls-files --others --exclude-standard`)\n````plaintext\n"
						.. untracked
						.. "````\n\n"
					local untracked_files = vim.split(untracked, "\n")
					for _, file in ipairs(untracked_files) do
						if file ~= "" then
							local cmd = "git diff --no-index /dev/null " .. file
							local s = vim.fn.system(cmd)
							if s ~= "" then
								git_status = git_status
									.. "##### Diff For Untracked File "
									.. file
									.. " (`"
									.. cmd
									.. "`)\n````diff\n"
								git_status = git_status .. s .. "````\n\n"
							end
						end
					end
				end

				return git_status
			end,
		},
	},
}
