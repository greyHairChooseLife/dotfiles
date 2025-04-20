local M = {}

local utils = require("utils")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local builtin = require("telescope.builtin")
local previewers = require("telescope.previewers")

-- MEMO:: previewers
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
local wide_layout_config = { preview_width = 0.8, width = 0.9, height = 0.9 }
local commits_delta = previewers.new_termopen_previewer({
	get_command = function(entry)
		return { "git", "show", entry.value }
	end,
})
-- install git-delta from pacman
local diff_delta = previewers.new_termopen_previewer({
	get_command = function(entry)
		-- 추적되지 않은 파일
		if entry.status == "??" then
			return {
				"bash",
				"-c",
				'echo "This is an untracked file. No diff available.\n\nJust stage it, so you can have a look."',
			}
		end

		-- staged & unstaged
		return { "git", "diff", "HEAD", "--", entry.path }
		-- 원한다면 아래처럼도 가능
		-- return { 'bash', '-c', 'git diff HEAD -- ' .. entry.path }

		-- -- staged only
		-- if entry.status == 'A ' then return { 'git', 'diff', '--cached', entry.path } end
	end,
})
local stash_delta = previewers.new_termopen_previewer({
	get_command = function(entry)
		-- 스태시 항목을 선택했을 때 diff 보여주기
		return { "git", "stash", "show", "-p", entry.value }
	end,
})
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-- MEMO: about terminal
local focus_or_open_terminal_buffer = function(prompt_bufnr)
	local entry = action_state.get_selected_entry()
	local filepath = entry.path or entry.filename
	local bufnr = entry.bufnr -- 버퍼 선택기에서는 bufnr 필드를 사용

	local function is_buffer_open(filepath, bufnr)
		local buffers = vim.api.nvim_list_bufs()
		for _, buf in ipairs(buffers) do
			if vim.api.nvim_buf_is_loaded(buf) then
				local bufname = vim.api.nvim_buf_get_name(buf)

				-- 파일 경로나 버퍼 번호가 일치하는지 확인
				if bufname == filepath or buf == bufnr then
					-- 모든 탭과 창을 순회하여 버퍼가 열린 창이 있는지 확인
					for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
						for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
							if vim.api.nvim_win_get_buf(win) == buf then
								return true, buf -- 다른 탭이나 창에서 열린 상태라면 true 반환
							end
						end
					end
				end
			end
		end
		return false
	end

	local is_opened, buf = is_buffer_open(filepath, bufnr)

	if is_opened then
		actions.close(prompt_bufnr)

		-- 열려있는 버퍼의 창으로 포커스를 이동
		local wins = vim.api.nvim_list_wins()
		for _, win in ipairs(wins) do
			if vim.api.nvim_win_get_buf(win) == buf then
				vim.api.nvim_set_current_win(win)

				-- picker마다 기본 동작을 유지하기 위해 resume 후 select_default 호출
				builtin.resume()
				vim.schedule(function()
					local new_picker_bufnr = vim.api.nvim_get_current_buf()
					actions.select_default(new_picker_bufnr)
				end)
				return
			end
		end
	else
		-- 버퍼가 열려있지 않다면 선택된 기본 동작을 실행
		actions.select_default(prompt_bufnr)
	end
end

M.terminal_buffer_search = function()
	builtin.buffers({
		default_text = "Term: ",
		prompt_title = "Terminals",
		attach_mappings = function(_, map)
			map({ "i", "n" }, "<CR>", function(_prompt_bufnr)
				focus_or_open_terminal_buffer(_prompt_bufnr)
			end)

			map({ "i" }, "<C-r>", function(_prompt_bufnr)
				local default_text = "Term:  " -- 왜인지 두 칸을 띄워야한다.
				vim.cmd("normal! dd")
				vim.cmd("normal! i" .. default_text)
			end)

			map({ "n" }, "<C-r>", function(_prompt_bufnr)
				local default_text = "Term:  " -- 왜인지 두 칸을 띄워야한다.
				vim.cmd("normal! dd")
				vim.cmd("normal! i" .. default_text)
				vim.cmd("startinsert")
			end)

			return true -- default mapping applied as well
		end,
	})
end

-- MEMO: about git
M.git_commits = function()
	builtin.git_commits({
		git_command = {
			"git",
			"log",
			"--pretty=oneline",
			"--abbrev-commit",
			"HEAD",
			"--decorate",
			"--exclude=refs/stash",
		},
		previewer = commits_delta,
		layout_config = wide_layout_config,
	})
end

M.git_bcommits = function()
	builtin.git_bcommits({
		git_command = {
			"git",
			"log",
			"--pretty=oneline",
			"--abbrev-commit",
			"HEAD",
			"--decorate",
			"--exclude=refs/stash",
		},
		previewer = commits_delta,
		layout_config = wide_layout_config,
	})
end

M.git_diff = function()
	builtin.git_status({
		previewer = diff_delta,
		layout_config = wide_layout_config,
	})
end

M.git_stash = function()
	builtin.git_stash({
		previewer = stash_delta,
		layout_config = wide_layout_config,
	})
end

-- MEMO: about general
M.visual_file = function()
	local search_text = utils.get_visual_text()
	builtin.find_files({ default_text = search_text })
end
M.visual_live_grep = function()
	local search_text = utils.get_visual_text()
	builtin.live_grep({ default_text = search_text })
end
M.live_grep_current_buffer = function()
	local scope = vim.fn.expand("%:p")
	builtin.live_grep({
		search_dirs = { scope },
	})
end
M.visual_live_grep_current_buffer = function()
	local scope = vim.fn.expand("%:p")
	local search_text = utils.get_visual_text()
	builtin.live_grep({
		search_dirs = { scope },
		default_text = search_text,
	})
end
M.visual_grep_string = function()
	local search_text = utils.get_visual_text()
	builtin.grep_string({ search = search_text })
end
M.buffers_without_terminal = function()
	utils.close_empty_unnamed_buffers()
	builtin.buffers({ file_ignore_patterns = { "^Term:" } }) -- 터미널 버퍼는 제외
end

return M
