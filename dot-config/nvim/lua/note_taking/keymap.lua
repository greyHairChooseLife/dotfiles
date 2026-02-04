local map = vim.keymap.set
local opt = { noremap = true, silent = true }
local wk_map = require("utils").wk_map

-- MEMO:: Global-Note
wk_map({
    ["<Space>n"] = {
        group = "Note",
        order = { "r", "t", "T", "g" },
        ["g"] = {
            function()
                local gn = require("global-note")
                gn.close_all_notes()
                gn.toggle_note() -- default_note aka. global
            end,
            desc = "open Global Note",
            mode = { "n", "v" },
        },
        ["r"] = {
            function()
                local gn = require("global-note")
                gn.close_all_notes()
                gn.toggle_note("project_local")
            end,
            desc = "open Local README.md",
            mode = { "n", "v" },
        },
        ["t"] = {
            function()
                local gn = require("global-note")
                gn.close_all_notes()
                gn.toggle_note("project_local_todo")
            end,
            desc = "open Local TODO.md",
            mode = { "n", "v" },
        },
        ["T"] = {
            function()
                local gn = require("global-note")
                gn.close_all_notes()
                gn.toggle_note("global_todo")
            end,
            desc = "open Global TODO.md",
            mode = { "n", "v" },
        },
    },
})
