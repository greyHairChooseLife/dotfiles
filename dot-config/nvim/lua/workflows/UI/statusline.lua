local function c_copilot_chat()
	-- local ft = vim.bo.filetype
	-- if ft ~= "copilot-chat" then
	-- 	return ""
	-- end

	local async = require("plenary.async")
	local chat = require("CopilotChat")
	local config = chat.config
	local model = config.model

	async.run(function()
		local resolved_model = chat.resolve_model()
		if resolved_model then
			model = resolved_model
		end
	end, function(_, _)
		-- Nothing to do here since we're just updating a local variable
	end)

	local status = { model .. " " }
	return table.concat(status, " ")
end

function _G.status_line_copilot_chat()
	local hl = "%#StatusLine#"

	return table.concat({
		hl,
		"%=",
		c_copilot_chat(),
	}, " ")
end
