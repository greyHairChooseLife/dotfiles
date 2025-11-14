local map = vim.keymap.set

local my_picker_src = require("picker.modules.picker_sources")
local extra = require("picker.modules.extra_sources")
local snp = require("snacks").picker

-- Git
-- TODO:: delta 적용
map("n", ",.gl", my_picker_src.git_log)
map("v", ",.gl", my_picker_src.git_log_line)
map("n", ",..gl", my_picker_src.git_log_file)
map("n", ",.gd", my_picker_src.git_diff)
map("n", ",.gss", my_picker_src.git_stash)
map("n", ",.gst", my_picker_src.git_status)
map("n", ",.gbr", my_picker_src.git_branches)
map("n", ",.ghi", function() snp.gh_issue() end)
map("n", ",.ghI", function() snp.gh_issue({ state = "all" }) end)
map("n", ",.ghp", function() snp.gh_pr({ layout = "right_dropdown" }) end)
map("n", ",.ghP", function() snp.gh_pr({ layout = "right_dropdown", state = "all" }) end)
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
map("v", ",.W", my_picker_src.grep_current_buffers_visual)
map({ "n", "x" }, ",.c", my_picker_src.grep_word)
map("n", ",.z", my_picker_src.grep_current_buffer)
map("v", ",.z", my_picker_src.grep_current_buffer_visual)
-- Diagnostics
map("n", ",.d", function() snp.diagnostics_buffer({ layout = "ivy_split" }) end)
map("n", ",.D", function() snp.diagnostics({ layout = "ivy_split" }) end)
map("n", ",.s", function() snp.lsp_symbols({ layout = "lsp_select" }) end)
map("n", ",.S", function() snp.lsp_workspace_symbols() end)

-- Etc
map("n", ",.,.", function() snp.pick({ layout = "select" }) end)
map("n", ",.C", my_picker_src.command_history)
map("n", ",.r", function() snp.registers({ layout = "select" }) end)
map("n", ",.q", function() snp.qflist({ layout = "right" }) end)
map("n", ",.m", function() snp.marks({ layout = "dropdown" }) end)
map("n", ",.R", snp.resume)
map("n", ",.H", function() snp.help({ layout = { fullscreen = true } }) end)
map("n", ",.h", function() snp.man({ layout = "ivy" }) end)
map("n", ",.N", function() snp.pick({ source = "noice", layout = "ivy_split" }) end)

map("n", "<Space>s", snp.snippets)
-- DEPRECATED:: 2025-11-03
map("n", ",.P", snp.pull_requests)
map("n", ",.M", function() extra.markdown_headings() end)
