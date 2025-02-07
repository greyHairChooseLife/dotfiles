function ShowCursor()
	vim.cmd("hi Cursor blend=0")
	vim.cmd("set guicursor-=a:Cursor/lCursor")
end

function NvimTreeResetUI()
	vim.cmd("NvimTreeClose")
	require("nvim-tree.api").tree.toggle({ find_files = true, focus = false })

	ShowCursor()
end

function ToggleTree()
	local tree_api = require("nvim-tree.api").tree

	tree_api.toggle({ find_files = true, focus = false })
	if tree_api.is_visible() then
		ShowCursor()
	end
end
