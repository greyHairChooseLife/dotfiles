vim.api.nvim_create_autocmd("FileType", {
	pattern = "vimwiki",
	callback = function()
		-- callouts
		vim.keymap.set("i", ",,qt", function()
			vim.api.nvim_put({ "> [!qt] ", ">   󱞪 " }, "c", false, true)

			-- 커서를 [!qt]의 q 뒤로 이동
			local row = unpack(vim.api.nvim_win_get_cursor(0))
			vim.api.nvim_win_set_cursor(0, { row - 1, 10 })
		end)

		vim.keymap.set("i", ",,td", function()
			local date = vim.fn.system('date "+%Y-%m-%d"')
			date = date:gsub("\n$", "")
			vim.api.nvim_put({ "> [!td]" .. date, "> [-] ", ">  󱞪 " }, "c", false, true)

			-- 커서를 [!qt]의 q 뒤로 이동
			local row = unpack(vim.api.nvim_win_get_cursor(0))
			vim.api.nvim_win_set_cursor(0, { row - 1, 10 })
		end)

		vim.keymap.set("i", ",,rf", function()
			vim.api.nvim_put({ "> [!rf]" }, "l", false, true)
			vim.api.nvim_put({ "> " }, "c", false, true)
		end)

		vim.keymap.set("i", ",,co", function()
			vim.api.nvim_put({ "> [!" }, "c", false, true)
		end)

		-- Log callout
		vim.keymap.set("i", ",,lg", function()
			local date = vim.fn.system('date "+%Y-%m-%d"')
			date = date:gsub("\n$", "")
			-- vim.api.nvim_put({ "> [!lg] Log " .. date, "> - " }, 'c', false, true)
			vim.api.nvim_put({ "> [!lg] Log " .. date, "> " }, "c", false, true)

			-- 커서를 [!qt]의 q 뒤로 이동
			-- local row = unpack(vim.api.nvim_win_get_cursor(0))
			-- vim.api.nvim_win_set_cursor(0, { row - 1, 10 })
		end)

		-- callout: 개념정리
		vim.keymap.set("i", ",,cn", function()
			vim.api.nvim_put({ "> [!cn] 개념정리", "> ", "> " }, "c", false, true)
		end)

		vim.keymap.set("n", "<leader><leader>w", "<cmd>VimwikiIndex<CR>")
		vim.keymap.set("n", "<leader><leader>d", "<cmd>VimwikiDiaryIndex<CR>")

		local function ToggleBracket()
			local cursor_pos = vim.api.nvim_win_get_cursor(0)
			local line_num = cursor_pos[1]
			local col_num = cursor_pos[2]
			local line = vim.api.nvim_get_current_line()

			local header_pattern = "^#+%s"
			local link_pattern = "%[%s*.+%]%(.+%)"
			local unchecked_pattern = " %[%-%] $"
			local unchecked_inline = "%[%-%]"
			local checked_pattern = "%[x%]"

			-- 1. 현재 라인이 '# ', '## ', '### '... 혹은 링크 패턴으로 시작하는지 확인
			if string.match(line, header_pattern) or string.match(line, link_pattern) then
				if string.match(line, unchecked_pattern) then
					line = string.gsub(line, unchecked_pattern, "")
				else
					line = line .. " [-] "
				end
			else
				-- 2. 라인에 '[-]'가 있는지 확인
				if string.match(line, unchecked_inline) then
					line = string.gsub(line, unchecked_inline, "[x] ")
				elseif string.match(line, checked_pattern) then
					line = string.gsub(line, checked_pattern, "[-] ")
				else
					local before_cursor = string.sub(line, 1, col_num)
					local after_cursor = string.sub(line, col_num + 1)
					line = before_cursor .. "[-] " .. after_cursor

					vim.api.nvim_set_current_line(line)
					vim.api.nvim_win_set_cursor(0, { line_num, col_num + 5 })
					vim.cmd("startinsert!")
					return
				end
			end

			vim.api.nvim_set_current_line(line)
			vim.api.nvim_win_set_cursor(0, { line_num, col_num })
		end

		vim.keymap.set("n", "<Space><Space>", ToggleBracket)

		vim.keymap.set("i", ",,T", "<ESC>:VimwikiTable ")

		vim.keymap.set("n", "<C-k>", "<cmd>VimwikiPrevLink<CR>")
		vim.keymap.set("n", "<C-j>", "<cmd>VimwikiNextLink<CR>")

		vim.keymap.set("n", "<tab>", "<cmd>VimwikiVSplitLink 1 0<CR>")
		vim.keymap.set("n", "<S-tab>", "<cmd>VimwikiVSplitLink 1 1<CR>")

		local function insert_header()
			local filename = vim.fn.expand("%:t")
			filename = filename:gsub("_", " "):gsub("%.md$", "")
			local msg = "# 󰏢 " .. filename
			vim.api.nvim_buf_set_lines(0, 0, 0, false, { msg })
		end

		vim.keymap.set("i", ",,H", insert_header)
		vim.keymap.set("n", "<CR>", function()
			vim.cmd("VimwikiFollowLink")

			local filepath = vim.fn.expand("%:p")
			if vim.fn.filereadable(filepath) == 0 and vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
				insert_header()

				local template_path = vim.fn.expand("%:p:h") .. "/template.md"
				local lines = vim.fn.readfile(template_path)
				-- local lines = 'hello world!'

				-- 템플릿 파일 내용을 현재 버퍼에 삽입
				vim.api.nvim_buf_set_lines(0, 2, 2, false, lines)

				vim.cmd("normal! zR")
			end
		end)

		vim.keymap.set("n", "<Backspace>", "<cmd>VimwikiGoBackLink<CR>")

		vim.keymap.set("v", "<CR>", "<Plug>VimwikiNormalizeLinkVisual", { noremap = false, silent = true })

		vim.keymap.set("n", "<leader>wd", "<cmd>VimwikiDeleteFile<CR>")
		vim.keymap.set("n", "<leader>wr", "<cmd>VimwikiRenameFile<CR>")

		vim.keymap.set("n", "<C-p>", "<Plug>VimwikiGoToPrevHeader", { noremap = true, silent = true })
		vim.keymap.set("n", "<C-n>", "<Plug>VimwikiGoToNextHeader", { noremap = true, silent = true })
		vim.keymap.set("n", "<C-[>", "<Plug>VimwikiGoToPrevSiblingHeader", { noremap = true, silent = true })
		vim.keymap.set("n", "<C-]>", "<Plug>VimwikiGoToNextSiblingHeader", { noremap = true, silent = true })

		-- vim.keymap.set('n', '<C-p>', '<Plug>VimwikiGoToPrevHeader', { noremap = true, silent = true })
		-- vim.keymap.set('n', '<C-n>', '<Plug>VimwikiGoToNextHeader', { noremap = true, silent = true })
		--
		-- -- START_debug:: 저장 관련 버그가 발생한다.
		-- -- vim.keymap.set('n', '<C-Up>', '<Plug>VimwikiGoToPrevSiblingHeader', { noremap = true, silent = true })
		-- -- vim.keymap.set('n', '<C-Down>', '<Plug>VimwikiGoToNextSiblingHeader', { noremap = true, silent = true })
		-- -- END___debug:

		-- delete keymap
		vim.keymap.del("n", "<Esc>") -- 노멀모드에서 esc 누르면 sibling heading을 찾는다.
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "codecompanion" },
	callback = function()
		-- KEYMAPS
		vim.keymap.set("v", "<C-b>", ":lua require('markdowny').bold()<cr>", { buffer = true })
		vim.keymap.set("v", "<C-i>", ":lua require('markdowny').italic()<cr>", { buffer = true })
		vim.keymap.set("v", "<C-c>", ":lua require('markdowny').cancel()<cr>", { buffer = true })
		vim.keymap.set("v", "<C-k>", ":lua require('markdowny').link()<cr>", { buffer = true })
		vim.keymap.set("v", "<C-e>", ":lua require('markdowny').code()<cr>", { buffer = true })
	end,
})
