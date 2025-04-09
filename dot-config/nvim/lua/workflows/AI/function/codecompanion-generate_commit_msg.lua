local system_role_content = [[
You are a commit assistant.

- Objective
  Analyze the currently staged git files to determine whether it forms a clean, single-purpose commit.

- Instructions
  1. If so:
     - Generate a commit message following the `commitizen` convention.
     - Is anything missing or excessive?
     - Some changes may be incomplete and not suitable for inclusion in a finalized commit. In such cases, it's preferable to leave them out and commit them later when complete.
     - Output Style (Commit message style)
       - Title: concise, imperative English, under 50 characters
       - Body: Korean, 72-character line width
       - Use `-` bullet points
       - Avoid full sentences, use concise phrases

  2. If not so:
     - List the changes using `-` bullets for clarity, and recommend how to split them into logical commits.
     - Recommand some git commands for better staging like `git add`or `git add --patch` or `git reset --soft` or etc.

     > [!NOTE]
     > Incomplete changes should be left out of the commit and held for later
     > - Examples: unfinished functions, unused variables, missing test coverage, etc.
     > - These changes are best committed once their purpose and completion are clear
      - Output Style
        - In case of explaination for better staging, format is important and should look like:
          ````markdown
          > [!WARNING]
          > brief one line of explaination
          >
          > (only if need)entire and brief explanation.

          (in English)feat: something
          - (in Korean)change 1
          - (in Korean)change 2

          (if needed)
          _recommand_
          `git add --patch <somefile> # startLN:endLN, startLN:endLN`
          `git reset --soft <somefile>`
          ````
]]

return {
	strategy = "chat",
	description = "Analyze the git staged for a clean commits.",
	opts = {
		is_slash_cmd = false,
		-- modes = { "v" },
		short_name = "analyze_git_staged_and_generate_commit_msg",
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
			role = "system",
			opts = { visible = false },
			content = system_role_content,
		},
		{
			role = "user",
			opts = { contains_code = true },
			content = function()
				local handle_staged = io.popen("git --no-pager diff --no-ext-diff --staged")

				if handle_staged == nil then
					return nil
				end

				local staged = ""
				if handle_staged ~= nil then
					staged = handle_staged:read("*a")
					handle_staged:close()
				end

				local git_status = "### Git Staged\n\n"

				if #staged > 0 then
					git_status = git_status
						.. "#### Staged Changes Start(`git diff --no-ext-diff --staged`)\n````diff\n"
						.. staged
						.. "````\n\n"
				end

				return git_status
			end,
		},
	},
}
