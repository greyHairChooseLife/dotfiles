local user_role_content = [[
Take a look at specifications and generate todo list to TODO.md using @editor
]]

return {
	strategy = "chat",
	description = "",
	opts = {
		is_default = true, -- don't show on action palette
		is_slash_cmd = true,
		short_name = "workspace todo list",
		auto_submit = false,
		user_prompt = true,
		ignore_system_prompt = true,
		stop_context_insertion = false,
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
