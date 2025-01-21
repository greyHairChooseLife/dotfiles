local opts = { buffer = true, silent = true }
local utils = require("utils")

vim.api.nvim_create_autocmd("FileType", {
	pattern = "NvimTree",
	callback = function()
		-- load resource
		local api = require("nvim-tree.api")

		-- gui

		-- local function
		local function open_oil_relatively(mode) -- oil 켜기
			-- 일단 기존의 oil 버퍼를 닫는다.
			utils.close_FT_buffers("oil")

			-- nvim-tree API를 이용해 현재 커서 위치의 노드 가져오기
			local node = require("nvim-tree.api").tree.get_node_under_cursor()

			if node then
				local path

				if node.type == "file" then
					-- 파일인 경우 부모 디렉토리 경로 가져오기
					path = vim.fn.fnamemodify(node.absolute_path, ":h")
				elseif node.type == "directory" then
					-- 디렉토리인 경우 해당 디렉토리 경로 사용
					path = node.absolute_path
				end

				-- 경로가 nil인지 확인하여 최상위 경로 처리
				if path and (path == "/" or path == vim.fn.fnamemodify(path, ":h")) then
					path = node.absolute_path
				end

				if mode == "tab" then
					vim.cmd("tabnew")
					local tabnr = vim.fn.tabpagenr()
					vim.fn.settabvar(tabnr, "tabname", "Oil")
				else
					vim.cmd("vsplit")
				end

				-- path가 유효한지 확인 후 작업 수행
				if path then
					require("oil").open(path) -- 필요한 경우 이 부분을 활용
				else
					require("oil").open()
				end
			else
				vim.notify("No node selected in nvim-tree.")
			end
		end

		-- keymap
		vim.keymap.set({ "n", "v" }, "-", function()
			open_oil_relatively()
		end, opts)
		vim.keymap.set({ "n", "v" }, "_", function()
			open_oil_relatively("tab")
		end, opts)
		vim.keymap.set({ "n", "v" }, "i", function()
			local oil = require("oil")
			local util = require("oil.util")
			local node = require("nvim-tree.api").tree.get_node_under_cursor()

			utils.close_FT_buffers("oil") -- 기존 oil 버퍼는 닫는다.

			path = vim.fn.fnamemodify(node.absolute_path, ":h")
			name = node.name
			-- oil을 열고
			vim.cmd("vsplit")
			oil.open(path)
			-- oil이 메모리에 로딩 되고 나면,
			util.run_after_load(0, function()
				vim.cmd("NvimTreeClose") -- nvim-tree를 닫는다.
				vim.cmd("normal ggO") -- oil 버퍼의 첫 줄로 이동, 한 줄 띄우고
				-- 그 자리에 가상 텍스트로 현재 oil path를 표시한다.
				local buf = vim.api.nvim_get_current_buf()
				modified_path = string.gsub(path, "^/home/sy", "~")
				vim.api.nvim_buf_set_virtual_text(buf, 0, 0, { { modified_path .. "/..", "NvimTreeRootFolder" } }, {})
				-- nvim-tree에서 포커싱된 노드로 커서 이동
				vim.fn.search(name)
			end)
		end, opts)

		vim.keymap.set({ "n", "v" }, "<A-v>", function()
			vim.cmd("vnew")
			NvimTreeResetUI()
		end, opts)

		vim.keymap.set({ "n", "v" }, "gq", function()
			vim.cmd("q | wincmd p")
			BlinkCursorLine(500)
		end, opts)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "oil",
	callback = function()
		-- GUI
		vim.api.nvim_set_hl(0, "OilBufferHighlight", { bg = "#1A1601" })
		vim.api.nvim_set_hl(0, "OilBufferEOB", { fg = "#1A1601" })
		vim.cmd("setlocal winhighlight=Normal:OilBufferHighlight,EndOfBuffer:OilBufferEOB")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "harpoon",
	callback = function()
		-- GUI

		-- KEYMAP
		vim.keymap.set("n", "gq", function()
			vim.cmd("silent q")
		end, { buffer = true })
		vim.keymap.set("n", "gw", function()
			vim.cmd("silent w")
			vim.notify("Harpoon Updated", 3, { render = "minimal" })
		end, { buffer = true })
		vim.keymap.set("n", "ge", function()
			vim.cmd("silent w")
			vim.notify("Harpoon Updated", 3, { render = "minimal" })
		end, { buffer = true })
	end,
})
