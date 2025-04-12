local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- DEPRECATED:: 2025-02-06, which-key
-- NVIM-TREE
-- map("n", ",,d", ToggleTree)
-- map("n", ",d", "<cmd>NvimTreeFocus<CR>")

local M = {}

M.nvim_tree_on_attach = function(bufnr)
	local api = require("nvim-tree.api")
	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- put some default mappings here
	-- user mappings
	vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
	vim.keymap.set("n", ".", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))
	vim.keymap.set("n", "r", function()
		api.tree.change_root_to_node()
		api.tree.toggle() -- lualine 표시를 위해
		api.tree.toggle()
	end, opts("CD"))
	vim.keymap.set("n", "h", function()
		local line = vim.fn.line(".")
		local node = api.tree.get_node_under_cursor()

		if line == 1 then -- 최상위 디렉토리 노드
			api.tree.change_root_to_parent()
			api.tree.toggle() -- lualine 표시를 위해, reload는 branch 표시가 부족하다.
			api.tree.toggle()
		elseif node.type == "directory" and node.open then
			api.node.open.preview() -- 그냥 닫기만 해
		else -- 닫힌 디렉퇼 또는 파일이면
			api.node.navigate.parent() -- 부모 디엑토리로 이동만
		end
	end, opts("Up"))
	vim.keymap.set("n", "K", api.node.show_info_popup, opts("Info"))
	vim.keymap.set("n", "o", function()
		api.node.open.edit()
		api.tree.open()
	end, opts("Open Without Focus"))
	vim.keymap.set("n", "O", api.node.open.edit, opts("Open"))
	vim.keymap.set("n", "T", api.node.open.tab, opts("Open in New Tab"))
	vim.keymap.set("n", "l", function()
		local node = api.tree.get_node_under_cursor()
		if node.type == "directory" then
			if not node.open then -- is_dir_expanded?
				-- from help doc
				-- node.open.edit({node})                        *nvim-tree-api.node.open.edit()*
				--     File:   open as per |nvim-tree.actions.open_file|
				--     Folder: expand or collapse
				--     Root:   change directory up
				api.node.open.edit()
			end
			vim.cmd("normal j")
		else
			vim.cmd("vert rightbelow new")
			vim.cmd("edit " .. node.absolute_path)
			NvimTreeResetUI()
			vim.cmd("NvimTreeFocus")
		end
	end, opts("action l"))
	vim.keymap.set("n", "L", function()
		local node = api.tree.get_node_under_cursor()
		if node.type == "directory" then
			if not node.open then
				api.node.open.edit()
			end
			vim.cmd("normal j")
		else
			vim.cmd("vert rightbelow new")
			vim.cmd("edit " .. node.absolute_path)
			NvimTreeResetUI()
		end
	end, opts("action L"))
	vim.keymap.set("n", "N", api.fs.create, opts("Create"))
	vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
	vim.keymap.set("n", "X", api.fs.cut, opts("Cut"))
	vim.keymap.set("n", "C", api.fs.copy.node, opts("Copy"))
	vim.keymap.set("n", "P", api.fs.paste, opts("Paste"))
	vim.keymap.set("n", "R", api.fs.rename, opts("Rename"))
	vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Filter: Git Ignore"))
	vim.keymap.set("n", "<Tab>", api.marks.toggle, opts("Toggle Bookmark"))
	vim.keymap.set("n", "M", api.tree.toggle_no_bookmark_filter, opts("Toggle Filter: No Bookmark"))
	vim.keymap.set("n", "bD", api.marks.bulk.trash, opts("Trash Bookmarked"))
	vim.keymap.set("n", "bmv", api.marks.bulk.move, opts("Move Bookmarked"))
	vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
	vim.keymap.set("n", "p", api.node.navigate.parent, opts("Parent Directory"))

	vim.keymap.set("n", "cp", api.node.navigate.git.prev_recursive, opts("git prev"))
	vim.keymap.set("n", "cn", api.node.navigate.git.next_recursive, opts("git next"))
	vim.keymap.set("n", "bp", api.node.navigate.opened.prev, opts("active buffer prev"))
	vim.keymap.set("n", "bn", api.node.navigate.opened.next, opts("active buffer next"))

	vim.keymap.set("n", "zr", api.tree.expand_all, opts("Expand All"))
	vim.keymap.set("n", "zm", api.tree.collapse_all, opts("Collapse"))
	vim.keymap.set("n", "ya", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
	vim.keymap.set("n", "yr", api.fs.copy.relative_path, opts("Copy Relative Path"))
	vim.keymap.set("n", "yf", api.fs.copy.filename, opts("Copy Name"))
	vim.keymap.set("n", "yp", function()
		local node = api.tree.get_node_under_cursor()
		local dir_path = node.absolute_path:match("(.*/)") or ""
		vim.fn.system("echo -n '" .. dir_path .. "' | xclip -selection clipboard")
		print("Copied " .. dir_path)
	end, opts("Copy Dir-path"))
	vim.keymap.set("n", ",r", function()
		if
			vim.bo.filetype == "NvimTree"
			and #vim.api.nvim_tabpage_list_wins(vim.api.nvim_get_current_tabpage()) == 1
		then
			require("nvim-tree.api").tree.reload()
		else
			-- require('nvim-tree.api').tree.reload()
			-- require('nvim-tree.api').tree.toggle({ find_files = true, focus = false })
			-- require('nvim-tree.api').tree.toggle({ find_files = true, focus = false })
			NvimTreeResetUI()
			vim.cmd("AerialToggle")
			vim.cmd("AerialToggle")
			require("quicker").refresh()
			vim.cmd("wincmd = | echon | wincmd h")
		end
	end, opts("Refresh"))

	-- MEMO:: git integration
	vim.keymap.set("n", "a", function()
		local node = api.tree.get_node_under_cursor()
		local gs = node.git_status.file

		-- not directory nor git working area
		if gs == nil and node.git_status.dir == nil then
			return
		end

		-- If the current node is a directory get children status
		if gs == nil then
			gs = (node.git_status.dir.direct ~= nil and node.git_status.dir.direct[1])
				or (node.git_status.dir.indirect ~= nil and node.git_status.dir.indirect[1])
		end

		-- If the file is untracked, unstaged or partially staged, we stage it
		if gs == "??" or gs == "MM" or gs == "AM" or gs == " M" then
			vim.cmd("silent !git add " .. node.absolute_path)

		-- If the file is staged, we unstage
		elseif gs == "M " or gs == "A " then
			vim.cmd("silent !git restore --staged " .. node.absolute_path)
		else
			return
		end

		api.tree.reload()
	end, opts("Git Add"))

	vim.keymap.set("n", "F", function()
		local node = api.tree.get_node_under_cursor()
		OpenFloatWindow({
			filepath = node.absolute_path,
		})
	end, opts("Open Float"))
end

return M
