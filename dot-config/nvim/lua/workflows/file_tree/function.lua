function ShowCursor()
	vim.cmd("hi Cursor blend=0")
	vim.cmd("set guicursor-=a:Cursor/lCursor")
end

function NvimTreeResetUI()
	vim.cmd("NvimTreeClose")
	require("nvim-tree.api").tree.toggle({ find_files = true, focus = false })

	ShowCursor()
end
