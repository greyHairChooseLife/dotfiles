local user_role_content_bak = [[
I need your help developing comprehensive specifications for a project. I have several skeleton files that need to be filled with detailed, coherent information.

To gather the necessary information:

1. Please ask me a sequence of targeted questions about this project, working systematically through its core aspects
2. Adapt your questions based on whether we're working on:
   - Technical specifications (architecture, technologies, integration points)
   - Business requirements (objectives, metrics, rules)
   - User experience (personas, journeys, interfaces)
   - Any other domain-specific aspects

Continue asking focused questions that build upon my previous answers until you have enough information to create complete, professional specification documents. Each question should help develop a coherent understanding of the project requirements.

Once you have sufficient information, let me know you're ready to complete the files

The goal is creating specification documents that provide clear direction to a project team while ensuring all requirements are properly documented and organized.

There are a result of an earlier discussions so you must consider based on that.
]]

local user_role_content = [[
I need comprehensive specifications for a software development project. I have multiple skeleton files that require detailed, coherent content.

Please conduct a systematic requirements gathering process:

1. **File Organization**:
   - Review all provided skeleton files first
   - Determine the logical order for completion based on dependencies and foundational requirements

2. **Smart Progression**:
   - Build each question on previous answers and earlier file content
   - Complete one file section before moving to the next
   - When you can reasonably predict answers based on context, propose them for my confirmation rather than asking open-ended questions within format like below:
     Format:
     - All header must have one empty line of margin above and below.
     - Level 2 header(##) must have TWO empty lines above and one of it below.
     - Keep descriptions concise and direct
     - Use simple numbered lists without excessive nesting
     - Maintain clean spacing between sections
     - use '-' character for bullet point


3. **Efficiency Focus**:
   - Group related questions within each file to minimize back-and-forth
   - Reference information from previously completed files to avoid redundancy
   - Flag any cross-file dependencies or conflicts

4. **Completion Criteria**: Signal when you have sufficient information for each file's section, then proceed to the next in sequence.

Note: This builds on earlier discussions, so consider that existing context when forming your approach.

Goal: Professional specification documents with all requirements properly documented and organized for immediate development use.
]]

return {
    strategy = "chat",
    description = "",
    opts = {
        is_default = true, -- don't show on action palette
        is_slash_cmd = true,
        short_name = "workspace generator",
        auto_submit = false,
        user_prompt = true,
        ignore_system_prompt = true,
        stop_context_insertion = true,
    },
    prompts = {
        {
            role = "user",
            opts = { contains_code = true },
            content = function()
                -- Enable turbo mode!!!
                vim.g.codecompanion_auto_tool_mode = true

                local chage_model = require("AI.codecompanion.utils.general").chage_model
                chage_model("gemini-2.5-pro")

                return user_role_content
            end,
        },
    },
}
