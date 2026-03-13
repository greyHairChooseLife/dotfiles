local map = vim.keymap.set

local my_picker_src = require("picker.modules.picker_sources")
local extra = require("picker.modules.extra_sources")
local default = require("snacks").picker

-- Git
map("n", ",.gl", my_picker_src.git_log)
map("v", ",.gl", my_picker_src.git_log_line)
map("n", ",..gl", my_picker_src.git_log_file)
map("n", ",.gd", my_picker_src.git_diff)
map("n", ",.gss", my_picker_src.git_stash)
map("n", ",.gst", my_picker_src.git_status)
map("n", ",.gbr", my_picker_src.git_branches)

-- Github
map("n", ",.gha", function() default.gh_actions() end)
map("n", ",.ghi", function() default.gh_issue() end)
map("n", ",.ghI", function() default.gh_issue({ state = "all" }) end)
map("n", ",.ghp", function() default.gh_pr({ layout = "right_dropdown" }) end)
map("n", ",.ghP", function() default.gh_pr({ layout = "right_dropdown", state = "all" }) end)

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
map("n", ",.d", function() default.diagnostics_buffer({ layout = "ivy_split" }) end)
map("n", ",.D", function() default.diagnostics({ layout = "ivy_split" }) end)
map("n", ",.s", function() default.lsp_symbols({ layout = "lsp_select" }) end)
map("n", ",.l", function() default.treesitter({ layout = "lsp_select" }) end)
map("n", ",.S", function() default.lsp_workspace_symbols() end)

-- Etc
map("n", ",.,.", function() default.pick({ layout = "select" }) end)
map("n", ",.C", my_picker_src.command_history)
map("n", ",.r", function() default.registers({ layout = "select" }) end)
map("n", ",.q", function() default.qflist({ layout = "right" }) end)
local marks_filter = function(item) return item.label:match("^[a-zA-Z]$") and item or false end
map("n", ",.m", function() default.marks({ global = false, layout = "right", transform = marks_filter }) end)
map("n", ",.M", function() default.marks({ global = true, ["local"] = false, layout = "dropdown", transform = marks_filter }) end)
map("n", ",.R", default.resume)
map("n", ",.H", function() default.help({ layout = { fullscreen = true } }) end)
map("n", ",.h", function() default.man({ layout = "ivy" }) end)
map("n", ",.N", function() default.pick({ source = "noice", layout = "ivy_split" }) end)
map("n", "<Space>s", default.snippets)
map("n", ",.n", function() extra.markdown_headings() end)

-- DEPRECATED:: 2025-11-03
-- map("n", ",.P", default.pull_requests)
