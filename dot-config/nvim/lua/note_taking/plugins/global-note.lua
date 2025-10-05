return {
    "greyhairchooselife/global-note.nvim",
    -- dir = "/home/sy/neovim-plugin/global-note.nvim",
    cmd = { "GlobalNote", "LocalNote" },
    opts = {
        -- NOTE:
        -- -- Check if the default note is open
        -- local is_default_open = require("global-note").is_note_open()
        -- -- Check if a specific preset is open
        -- local is_todo_open = require("global-note").is_note_open("todo")
        -- -- Get a list of all open notes
        -- local open_notes = require("global-note").get_open_notes()
        -- -- Get the window ID for a specific note
        -- local window_id = require("global-note").get_note_window("todo")

        filename = "global-note.md",
        directory = "~/Documents/",
        title = "     Global     ",
        command_name = "GlobalNote",

        -- A nvim_open_win config to show float window.
        -- table or fun(): table
        window_config = function()
            local window_height = vim.api.nvim_list_uis()[1].height
            local window_width = vim.api.nvim_list_uis()[1].width
            return {
                relative = "editor",
                -- border = require("utils").borders.full,
                border = "double",
                -- Can be one of the pre-defined styles: `"double"`, `"none"`, `"rounded"`, `"shadow"`, `"single"` or `"solid"`.
                -- style = "minimal",
                title_pos = "right",
                width = math.floor(0.7 * window_width),
                height = math.floor(0.85 * window_height),
                row = math.floor(0.05 * window_height),
                col = math.floor(0.15 * window_width),
            }
        end,

        -- It's called after the window creation.
        -- fun(buffer_id: number, window_id: number)
        post_open = function(bufnr, _)
            -- 윈도우 옵션 설정
            -- vim.wo.winhl =
            -- 	"Normal:NoteBackground,FloatBorder:NoteBorder,FloatTitle:NoteTitle,EndOfBuffer:NoteEOB,FoldColumn:NoteFoldColumn"

            -- vim.wo.number = false
            -- vim.wo.foldcolumn = "2"
            -- vim.wo.relativenumber = false
            -- vim.wo.cursorline = false
            -- vim.wo.signcolumn = "no"

            -- 버퍼 옵션 설정
            vim.bo.filetype = "markdown"
            local function close_note()
                local gn = require("global-note")
                gn.close_all_notes()
            end
            vim.keymap.set("n", "gq", close_note, { buffer = bufnr })
            vim.keymap.set("n", "qq", close_note, { buffer = bufnr })
        end,

        additional_presets = {
            project_local = {
                command_name = "LocalNote",
                title = "     README     ",
                directory = function()
                    -- Try to get git root directory first
                    local git_root = vim.system({
                        "git",
                        "rev-parse",
                        "--show-toplevel",
                    }, {
                        text = true,
                    }):wait()

                    if git_root.code == 0 then
                        -- Remove trailing newline and return the git root
                        return git_root.stdout:gsub("\n", "") .. "/"
                    else
                        -- Fall back to current working directory
                        local cwd, err = vim.uv.cwd()
                        if cwd == nil then
                            vim.notify(err or "Unknown error getting current directory", vim.log.levels.WARN)
                            return "~/Documents/notes/" -- Fallback directory if cwd fails
                        end
                        return cwd .. "/"
                    end
                end,
                filename = function() return "README.md" end,

                post_open = function(_, _)
                    vim.wo.winhl = "Normal:NoteBackground,FloatBorder:LocalNoteBorder,FloatTitle:LocalNoteTitle,EndOfBuffer:NoteEOB,FoldColumn:NoteFoldColumn"
                    vim.wo.number = false
                    vim.wo.foldcolumn = "2"
                    vim.wo.relativenumber = false
                    vim.wo.cursorline = false
                    vim.wo.signcolumn = "no"
                end,
            },
            project_local_todo = {
                command_name = "LocalTodo",
                title = "      TODO      ",
                directory = function()
                    -- Try to get git root directory first
                    local git_root = vim.system({
                        "git",
                        "rev-parse",
                        "--show-toplevel",
                    }, {
                        text = true,
                    }):wait()

                    if git_root.code == 0 then
                        -- Remove trailing newline and return the git root
                        return git_root.stdout:gsub("\n", "") .. "/"
                    else
                        -- Fall back to current working directory
                        local cwd, err = vim.uv.cwd()
                        if cwd == nil then
                            vim.notify(err or "Unknown error getting current directory", vim.log.levels.WARN)
                            return "~/Documents/notes/" -- Fallback directory if cwd fails
                        end
                        return cwd .. "/"
                    end
                end,
                filename = function() return "TODO.md" end,

                post_open = function(_, _)
                    vim.wo.winhl = "Normal:NoteBackground,FloatBorder:LocalTodoBorder,FloatTitle:LocalTodoTitle,EndOfBuffer:NoteEOB,FoldColumn:NoteFoldColumn"
                    vim.wo.number = false
                    vim.wo.foldcolumn = "2"
                    vim.wo.relativenumber = false
                    vim.wo.cursorline = false
                    vim.wo.signcolumn = "no"
                end,
            },
        },
    },
}
