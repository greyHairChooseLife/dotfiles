local map = vim.keymap.set
local opt = { noremap = true, silent = true }
local wk_map = require("utils").wk_map
-- map({ "n", "v" }, ",.t", tele_func.terminal_buffer_search)

-- map("n", ",.gco", tele_func.git_commits)
-- map("n", ",.gbco", tele_func.git_bcommits)
-- map("n", ",.gd", tele_func.git_diff)
-- map("n", ",.gss", tele_func.git_stash)
-- map("n", ",.gst", builtin.git_status)
-- map("n", ",.gbr", builtin.git_branches)

-- map("n", ",.f", builtin.find_files)
-- map("v", ",.f", tele_func.visual_file)
-- map("n", ",.w", builtin.live_grep)
-- map("v", ",.w", tele_func.visual_live_grep)
-- map("n", ",..w", tele_func.live_grep_current_buffer)
-- map("v", ",..w", tele_func.visual_live_grep_current_buffer)
-- map("n", ",.c", builtin.grep_string)
-- map("v", ",.c", tele_func.visual_grep_string)
-- map("n", ",.b", tele_func.buffers_without_terminal)
-- map("n", ",.z", builtin.current_buffer_fuzzy_find) -- Regex search current file

-- map("n", ",.q", builtin.quickfix)
-- map({ "n", "i" }, ",.r", builtin.registers)
-- map("n", ",.m", builtin.marks)
-- map("n", ",.o", function()
-- 	builtin.oldfiles({ only_cwd = true })
-- end)

-- -- MEMO:: Telescope
-- wk_map({
-- 	[",."] = {
-- 		group = "Telescope",
-- 		order = { "R", "H", "N", "T" },
-- 		["R"] = { builtin.resume, desc = "resume", mode = "n" },
-- 		["H"] = { builtin.help_tags, desc = "help doc", mode = "n" },
-- 		["N"] = { "<cmd>Noice telescope<CR>", desc = "noice Log", mode = "n" },
-- 		["T"] = { "<cmd>TodoTelescope<CR>", desc = "todo Tags", mode = "n" },
-- 	},
-- })
-- wk_map({
-- 	[",.."] = {
-- 		group = "expand",
-- 		["T"] = {
-- 			function()
-- 				local dir_path = vim.fn.expand("%:p:h") -- 상대경로
-- 				local file_path = vim.fn.expand("%:t") -- 파일명
-- 				vim.cmd(string.format("TodoTelescope cwd=%s default_text=%s", dir_path, file_path))
-- 				vim.cmd("normal! a ")
-- 			end,
-- 			desc = "todo Tags current",
-- 			mode = "n",
-- 		},
-- 	},
-- })

local my_picker_src = require("picker.modules.picker_sources")
local snp = require("snacks").picker

-- Git
-- TODO:: delta 적용
map("n", ",.gl", my_picker_src.git_log)
map("v", ",.gl", my_picker_src.git_log_line)
map("n", ",.gfl", my_picker_src.git_log_file)
map("n", ",.gd", my_picker_src.git_diff)
map("n", ",.gss", my_picker_src.git_stash)
map("n", ",.gst", my_picker_src.git_status)
map("n", ",.gbr", my_picker_src.git_branches)
-- Find
map("n", ",.f", my_picker_src.files)
map("v", ",.f", my_picker_src.files_visual)
map("n", ",.b", my_picker_src.buffers)
map("n", ",.t", my_picker_src.buffers_term_only)
map("n", ",.o", my_picker_src.recent)
map("n", ",.O", my_picker_src.recent_global)
-- Grep
map("n", ",.w", my_picker_src.grep)
map("n", ",.W", my_picker_src.grep_current_buffers)
map("v", ",.w", my_picker_src.grep_visual)
map("v", ",.W", my_picker_src.grep_visual_current_buffers)
map({ "n", "x" }, ",.c", my_picker_src.grep_word)
map("n", ",.z", my_picker_src.grep_current_buffer)
-- Diagnostics
map("n", ",.d", snp.diagnostics)
map("n", ",..d", snp.diagnostics_buffer)

-- Etc
map("n", ",.,.", snp.pick)
map("n", ",.C", my_picker_src.command_history)
map("n", ",.r", snp.registers)
map("n", ",.q", snp.qflist)
map("n", ",.m", snp.marks)
map("n", ",.R", snp.resume)
map("n", ",.H", snp.help)
map("n", ",.N", function()
	snp.pick({ source = "noice" })
end)
