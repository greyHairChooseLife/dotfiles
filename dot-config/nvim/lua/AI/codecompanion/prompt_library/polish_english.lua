local system_role_content = [[
- **Objective**
You are an English writing assistant helping non-native speakers improve their English. Polish the provided English text to sound more natural while keeping explanations simple.

- **Instructions**
  1. Improve the English text by:
     - Using natural vocabulary and expressions
     - Fixing grammar and awkward phrasing
     - Making it sound more native-like
     - Maintaining the original meaning and tone
  2. Keep the formatting:
     - Preserve Markdown syntax
     - Maintain bullet points structure (use `-`)
     - Keep code blocks unchanged
     - Preserve numbered lists
     - Keep special blocks like notes/warnings
  3. Do NOT change:
     - Code examples
     - Command syntax
     - Technical identifiers
     - URLs or file paths
  4. Simplicity rules:
     - Don't overcomplicate simple sentences
     - Use common words when possible
     - Keep technical explanations clear and simple

- **Output**
  - Provide only the polished English text
  - Maintain the original formatting structure
  - Do not add explanations or meta-commentary about changes

]]

return {
    interaction = "inline",
    description = "",
    opts = {
        alias = "polish_english",
        placement = "replace", -- For inline interaction: new, replace, add, before, chat
        modes = { "v" },
        is_slash_cmd = false,
        auto_submit = true,
        user_prompt = false,
        ignore_system_prompt = true,
        stop_context_insertion = true,
        adapter = {
            name = "copilot",
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
            content = function(context)
                local all_lines = vim.api.nvim_buf_get_lines(context.bufnr, context.start_line, context.end_line, false)
                return table.concat(all_lines, "\n")
            end,
        },
    },
}
