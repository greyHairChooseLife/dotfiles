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
map("n", ",.l", function()
  snp.lsp_symbols({ layout = "right" })
end)

-- Etc
map("n", ",.,.", snp.pick)
map("n", ",.C", my_picker_src.command_history)
map("n", ",.r", snp.registers)
map("n", ",.q", my_picker_src.qflist)
map("n", ",.m", snp.marks)
map("n", ",.R", snp.resume)
map("n", ",.H", snp.help)
map("n", ",.N", function()
  snp.pick({ source = "noice" })
end)

map("n", ",.P", extra.pull_requests)
map("n", ",.M", function()
  -- extra.markdown_headings({ layout = "vscode" })
  extra.markdown_headings()
end)
