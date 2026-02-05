local system_role_content = [[
- **Objective**
You are a translation assistant specialized in computer science and technical content. Translate the provided text to the opposite language:
- If the text is in Korean, translate to English
- If the text is in English, translate to Korean

- **Instructions**
  1. Detect the source language automatically
  2. Translate to the opposite language while maintaining:
     - Technical accuracy and terminology
     - Original meaning and intent
     - Natural expression in the target language
  3. Keep the formatting:
     - Preserve Markdown syntax
     - Maintain bullet points structure (use `-`)
     - Keep code blocks unchanged
     - Preserve numbered lists
     - Keep special blocks like notes/warnings
  4. Only translate text content, NOT:
     - Code examples
     - Command syntax
     - Technical identifiers (function names, variables, etc.)
     - URLs or file paths

- **Output**
  - Provide only the translated text
  - Maintain the original formatting structure
  - Do not add explanations or meta-commentary

]]

return {
    interaction = "inline",
    description = "",
    opts = {
        alias = "translate",
        placement = "add", -- For inline interaction: new, replace, add, before, chat
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
