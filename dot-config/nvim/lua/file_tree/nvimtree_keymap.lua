local map = vim.keymap.set

local M = {}

M.nvim_tree_on_attach = function(bufnr)
	local api = require("nvim-tree.api")
	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- put some default mappings here
	-- user mappings
	map("n", "g?", api.tree.toggle_help, opts("Help"))
	map("n", ".", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))
	map("n", "r", function()
		api.tree.change_root_to_node()
		api.tree.toggle() -- lualine 표시를 위해
		api.tree.toggle()
	end, opts("CD"))
	map("n", "h", function()
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
	map("n", "K", api.node.show_info_popup, opts("Info"))
	map("n", "o", function()
		api.node.open.edit()
		api.tree.open()
	end, opts("Open Without Focus"))
	map("n", "O", api.node.open.edit, opts("Open"))
	map("n", "t", api.node.open.tab, opts("Open in New Tab"))
	map("n", "T", function()
		local node = api.tree.get_node_under_cursor()
		local target_file_path = node.absolute_path
		local m = require("buf_win_tab.modules.select_tab")
		m.selectTabAndOpen({ source_file_path = target_file_path })
	end, opts("Open in Selected Tab"))
	map("n", "l", function()
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
	map("n", "L", function()
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
	map("n", "N", api.fs.create, opts("Create"))
	map("n", "D", api.fs.trash, opts("Trash"))
	map("n", "X", api.fs.cut, opts("Cut"))
	map("n", "C", api.fs.copy.node, opts("Copy"))
	map("n", "P", api.fs.paste, opts("Paste"))
	map("n", "R", api.fs.rename, opts("Rename"))
	map("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Filter: Git Ignore"))
	map("n", "<Tab>", api.marks.toggle, opts("Toggle Bookmark"))
	map("n", "M", api.tree.toggle_no_bookmark_filter, opts("Toggle Filter: No Bookmark"))
	map("n", "bD", api.marks.bulk.trash, opts("Trash Bookmarked"))
	map("n", "bmv", api.marks.bulk.move, opts("Move Bookmarked"))
	map("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
	map("n", "p", api.node.navigate.parent, opts("Parent Directory"))

	map("n", "cp", api.node.navigate.git.prev_recursive, opts("git prev"))
	map("n", "cn", api.node.navigate.git.next_recursive, opts("git next"))
	map("n", "bp", api.node.navigate.opened.prev, opts("active buffer prev"))
	map("n", "bn", api.node.navigate.opened.next, opts("active buffer next"))

	map("n", "zr", api.tree.expand_all, opts("Expand All"))
	map("n", "zm", api.tree.collapse_all, opts("Collapse"))
	map("n", "ya", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
	map("n", "yr", api.fs.copy.relative_path, opts("Copy Relative Path"))
	map("n", "yf", api.fs.copy.filename, opts("Copy Name"))
	map("n", "yp", function()
		local node = api.tree.get_node_under_cursor()
		local dir_path = node.absolute_path:match("(.*/)") or ""
		vim.fn.system("echo -n '" .. dir_path .. "' | xclip -selection clipboard")
		print("Copied " .. dir_path)
	end, opts("Copy Dir-path"))
	map("n", ",r", function()
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
	map("n", "a", function()
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

	map("n", "F", function()
		local node = api.tree.get_node_under_cursor()
		OpenFloatWindow({
			filepath = node.absolute_path,
		})
	end, opts("Open Float"))
end

return M
