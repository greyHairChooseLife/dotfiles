local user_role_content = [[
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

return {
	strategy = "chat",
	description = "",
	opts = {
		is_default = true, -- don't show on action palette
		is_slash_cmd = true,
		short_name = "make specification",
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
