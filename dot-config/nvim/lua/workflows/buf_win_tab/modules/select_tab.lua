local M = {}

--- Shows a selection UI for tabs and executes a callback with the selected tab
---@param callback fun(tab_id: integer|nil) Function to call with the selected tab number (nil if cancelled)
M.selectTab = function(callback)
	-- Get list of tabs
	local tabs = {}
	for i = 1, vim.fn.tabpagenr("$") do
		local name = vim.fn.gettabvar(i, "tabname")
		table.insert(tabs, { id = i, name = i .. ": " .. vim.fn.fnamemodify(name, ":t") })
	end

	-- Show selection UI
	vim.ui.select(tabs, {
		prompt = "Select tab:",
		format_item = function(item)
			return item.name
		end,
	}, function(choice)
		if choice then
			callback(choice.id)
		else
			callback(nil)
		end
	end)
end

return M
