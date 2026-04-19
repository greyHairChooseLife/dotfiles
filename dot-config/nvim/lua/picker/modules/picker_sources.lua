local g_utils = require("utils")
local SN = require("snacks")
local snp = require("snacks").picker

local M = {}

-- MEMO: CUSTOM PICKER EXAMPLE
-- local function pick_cmd_result(picker_opts)
--     local git_root = SN.git.get_root()
--     local finder = function(opts, ctx)
--         return require("snacks.picker.source.proc").proc({
--             opts,
--             {
--                 cmd = picker_opts.cmd,
--                 args = picker_opts.args,
--                 transform = function(item)
--                     item.cwd = picker_opts.cwd or git_root
--                     item.file = item.text
--                 end,
--             },
--         }, ctx)
--     end
--
--     snp.pick({
--         source = picker_opts.name,
--         finder = finder,
--         preview = picker_opts.preview,
--         title = picker_opts.title,
--     })
-- end
--
-- M.example = function()
--     pick_cmd_result({
--         cmd = "git",
--         args = { "diff-tree", "--no-commit-id", "--name-only", "--diff-filter=d", "HEAD", "-r" },
--         name = "git_show",
--         title = "Git Last Commit",
--         preview = "git_show",
--     })
-- end

-- MEMO: GIT
local files_from_last_commit = function(commit_hash, log_picker)
    commit_hash = commit_hash or "HEAD"
    local git_root = SN.git.get_root()

    local finder = function(opts, ctx)
        return require("snacks.picker.source.proc").proc(
            vim.tbl_extend("force", opts, {
                cmd = "git",
                args = { "diff-tree", "--no-commit-id", "--name-only", "--diff-filter=d", commit_hash, "-r" },
                cwd = git_root,
                transform = function(item)
                    item.file = item.text
                    item.cwd = git_root
                    item.commit = commit_hash
                end,
            }),
            ctx
        )
    end

    snp.pick({
        source = "git_commit_files",
        finder = finder,
        preview = "git_show",
        title = "Git Commit Files: " .. commit_hash,
        layout = { fullscreen = true },
        actions = {
            quit_and_resume_log = function(picker)
                picker:close()
                if log_picker then
                    vim.schedule(function()
                        log_picker.layout:unhide()
                        log_picker:focus()
                    end)
                end
            end,
        },
        win = {
            input = {
                keys = {
                    ["gq"] = { "quit_and_resume_log", mode = { "n", "i" } },
                    ["<Esc>"] = { "quit_and_resume_log", mode = { "n", "i" } },
                },
            },
        },
    })
end
local log_actions = {
    open_picker_files_from_last_commit = function(picker)
        local select = picker:current().commit
        picker.layout:hide()
        vim.schedule(function() files_from_last_commit(select, picker) end)
    end,
    view_in_diffview = function(picker)
        local select = picker:current().commit
        local args = select .. "^!"
        vim.cmd("DiffviewOpen " .. args)
    end,
    rebase_interactively = function(picker)
        local select = picker:current().commit
        local args = select .. "^"
        vim.cmd("GV")
        vim.defer_fn(function() vim.cmd("Git rebase -i " .. args) end, 1)
    end,
}
local log_config = {
    auto_close = false,
    actions = log_actions,
    layout = { fullscreen = true },
    win = {
        input = {
            keys = {
                ["<c-o>"] = { "open_picker_files_from_last_commit", mode = { "n", "i" } },
                ["<c-t>"] = { "view_in_diffview", mode = { "n", "i" } },
                ["<c-r>i"] = { "rebase_interactively", mode = { "n", "i" } },
                ["<c-r><c-i>"] = { "rebase_interactively", mode = { "n", "i" } },
            },
        },
    },
}
M.git_log = function() snp.git_log(log_config) end
M.git_log_line = function() snp.git_log_line(log_config) end
M.git_log_file = function() snp.git_log_file(log_config) end
M.git_diff = function() snp.git_diff({ layout = { fullscreen = true } }) end
M.git_stash = function()
    local config = {
        actions = {
            stash_pop = function(picker)
                local select = picker:current().stash
                vim.cmd("Git stash pop " .. select)
                picker:close()
            end,
            stash_drop = function(picker)
                local select = picker:current().stash
                vim.cmd("Git stash drop " .. select)
                picker:close()
                M.git_stash()
            end,
        },
        win = {
            input = {
                keys = {
                    ["<c-p>"] = { "stash_pop", mode = { "n", "i" } },
                    ["<c-d>"] = { "stash_drop", mode = { "n", "i" } },
                },
            },
        },
    }
    snp.git_stash(config)
end
M.git_status = function() snp.git_status() end
M.git_branches = function()
    local config = { all = true, layout = { fullscreen = true } }
    snp.git_branches(config)
end

-- MEMO: FIND
M.files = function() snp.files() end
M.files_visual = function()
    snp.files({ on_show = function() vim.api.nvim_put({ g_utils.get_visual_text() .. " " }, "c", true, true) end })
end
M.buffers = function()
    g_utils.close_empty_unnamed_buffers()
    g_utils.save_cursor_position()
    local config = {
        current = true,
        sort_lastused = false,
        filter = {
            filter = function(item)
                if item.file then
                    local filename = item.file:match("([^/]+)$")
                    if filename and filename:match("^Term:") then
                        return false -- Filter out this item
                    end
                end
                return true -- Keep this item
            end,
        },
        actions = {
            close_and_stay = function(picker)
                picker:close()
                g_utils.restore_cursor_position()
            end,
            my_bufdelete = function(picker)
                picker.preview:reset()
                local non_buf_delete_requested = false
                local to_be_closed_win = {}
                for _, item in ipairs(picker:selected({ fallback = true })) do
                    if item.buf then
                        table.insert(to_be_closed_win, item.info.windows[1])
                        Snacks.bufdelete.delete(item.buf)
                    else
                        non_buf_delete_requested = true
                    end
                end
                if non_buf_delete_requested then Snacks.notify.warn("Only open buffers can be deleted", { title = "Snacks Picker" }) end
                picker.list:set_selected()
                picker.list:set_target()
                picker:find()

                picker:close()
                for _, win_id in ipairs(to_be_closed_win) do
                    vim.api.nvim_win_close(win_id, false)
                end
                picker:resume()
            end,
        },
        win = {
            input = {
                keys = {
                    ["gq"] = { "close_and_stay", mode = { "n", "i" } },
                    ["<c-d>"] = { "my_bufdelete", mode = { "n", "i" } },
                },
            },
        },
    }

    snp.buffers(config)
end
M.buffers_term_only = function()
    local config = {
        layout = {
            preset = "bottom",
            -- fullscreen = true,
        },
        title = "TERMINAL",
        current = true,
        filter = {
            filter = function(item)
                if item.file then
                    local filename = item.file:match("([^/]+)$")
                    if filename and filename:match("^Term:") then
                        return true -- Filter out this item
                    end
                end
            end,
        },
    }
    snp.buffers(config)
end
M.recent = function() snp.recent({ filter = { cwd = true } }) end
M.recent_global = function() snp.recent({ filter = { cwd = false } }) end

-- MEMO: ETC
M.qflist = function()
    local config = {
        actions = {
            remove_select = function(picker)
                local buf_id = picker:current()
                QF_RemoveItem(buf_id.idx, true)
                vim.schedule(M.qflist)
            end,
        },
        win = {
            input = {
                keys = {
                    ["<c-d>"] = { "remove_select", mode = { "n", "i" } },
                },
            },
        },
    }
    snp.qflist(config)
end

-- MEMO: GREP
M.grep = function() snp.grep(config) end
M.grep_visual = function()
    local config = { on_show = function() vim.api.nvim_put({ g_utils.get_visual_text() .. " " }, "c", true, true) end }
    snp.grep(config)
end
M.grep_current_buffer = function() snp.lines() end
M.grep_current_buffer_visual = function()
    local config = { on_show = function() vim.api.nvim_put({ g_utils.get_visual_text() .. " " }, "c", true, true) end }
    snp.lines(config)
end
M.grep_current_buffers = function() snp.grep_buffers({ need_search = true }) end
M.grep_current_buffers_visual = function()
    local config = { on_show = function() vim.api.nvim_put({ g_utils.get_visual_text() .. " " }, "c", true, true) end }
    snp.grep_buffers(config)
end
M.grep_word = function() snp.grep_word() end

return M
