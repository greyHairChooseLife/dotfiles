local system_role_content = [[
You are a commit assistant.

- Objective
  Analyze the currently staged git files to determine whether it forms a clean, single-purpose commit.

- Instructions
  1. If it's a clean, single-purpose commit:
     - Generate a commit message following the `commitizen` convention and matching the style of previous commits provided in the history.
     - Output Style:
       - Title: concise, imperative English, under 50 characters
       - Body: Korean, 72-character line width
       - Use `-` bullet points
       - Avoid full sentences, use concise phrases

  2. If it's not a clean, single-purpose commit:
     - First, output a diagnostic callout summarizing the staging status.
     - Then, provide a single markdown code block containing a sequence of commands and messages for each logical commit group.
     - Group each logical change as a "Step" with a comment.
     - Format for Multiple Commits:
       > [!WARNING]
       > (Brief one-line summary of why the current stage needs splitting)
       >
       > (Brief explanation of the suggested logical groups)

       ````markdown
       # Step 1: (Brief description of the first logical change)
       `git reset`
       `git add <files_for_step_1>`
       feat: (English title)
       - (Korean detail)

       # Step 2: (Brief description of the second logical change)
       `git add <files_for_step_2>`
       fix: (English title)
       - (Korean detail)
       ````

    3. After you finishall analyzation and answer it, try to commit or commits including other commands like `git reset`, `git add` using @{run_command}. Remember to include details of commit messages seperating with title of it with 2 linebreak, if they exist.

- Rules
  - Incomplete changes (unfinished functions, unused variables, etc.) should be excluded.
  - Titles must be in English; descriptions must be in Korean.
  - Match the style of the provided history for consistency.
  - Encapsulate all git commands and recommended messages within one code block.
]]

return {
    interaction = "chat", -- chat, inline, workflow
    description = "", -- shown in the Action Pallete
    tools = { "run_command" },
    opts = {
        alias = "generate_commit_msg", -- Allows the prompt to be triggered via :CodeCompanion /{alias}
        is_slash_cmd = false,
        -- modes = { "v" },
        auto_submit = true,
        user_prompt = false,
        ignore_system_prompt = true,
        stop_context_insertion = true,
        adapter = {
            name = "copilot",
            -- MEMO:: github copilot is not unlimited anymore
            -- model = "claude-3.5-sonnet",
            -- model = "gemini-3-flash-preview",
            model = "gpt-4.1",
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

                if handle_staged == nil then return nil end

                local staged = ""
                if handle_staged ~= nil then
                    staged = handle_staged:read("*a")
                    handle_staged:close()
                end

                local handle_history = io.popen("git log -n 5 --pretty=format:'%s%n%b'")
                local history = ""
                if handle_history ~= nil then
                    history = handle_history:read("*a")
                    handle_history:close()
                end

                local git_status = "### Recent Commit History (Last 5)\n````text\n" .. history .. "\n````\n\n### Git Staged\n\n"

                if #staged > 0 then
                    git_status = git_status .. "#### Staged Changes Start(`git diff --no-ext-diff --staged`)\n````diff\n" .. staged .. "````\n\n"
                end

                return git_status
            end,
        },
    },
}
