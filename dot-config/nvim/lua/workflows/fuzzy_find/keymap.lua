local map = vim.keymap.set
local opt = { noremap = true, silent = true }

local builtin = require("telescope.builtin")

local tele_func = require("workflows.fuzzy_find.function")

map({ "n", "v" }, ",.t", tele_func.terminal_buffer_search)

map("n", ",.gco", tele_func.git_commits)
map("n", ",.gbco", tele_func.git_bcommits)
map("n", ",.gd", tele_func.git_diff)
map("n", ",.gss", tele_func.git_stash)
map("n", ",.gst", builtin.git_status)
map("n", ",.gbr", builtin.git_branches)

map("n", ",.f", builtin.find_files)
map("v", ",.f", tele_func.visual_file)
map("n", ",.w", builtin.live_grep)
map("v", ",.w", tele_func.visual_live_grep)
map("n", ",..w", tele_func.live_grep_current_buffer)
map("v", ",..w", tele_func.visual_live_grep_current_buffer)
map("n", ",.c", builtin.grep_string)
map("v", ",.c", tele_func.visual_grep_string)
map("n", ",.m", builtin.marks)
map("n", ",.b", tele_func.buffers_without_terminal)
map("n", ",.z", builtin.current_buffer_fuzzy_find) -- Regex search current file

map("n", ",.q", builtin.quickfix)
map({ "n", "i" }, ",.r", builtin.registers)
map("n", ",.o", function()
	builtin.oldfiles({ only_cwd = true })
end)

map("n", ",.R", builtin.resume)
map("n", ",.H", builtin.help_tags)
map("n", ",.T", "<cmd>TodoTelescope<CR>")
