local map = vim.keymap.set
local opt = { noremap = true, silent = true }
local wk_map = require("utils").wk_map

-- MEMO:: Json Format
wk_map({
    [","] = {
        order = { "j" },
        ["j"] = { Format_json_with_jq, desc = "format to JSON with jq", mode = "v" },
    },
})

-- MEMO:: format
wk_map({
    [",f"] = {
        order = { "f", "t" },
        ["f"] = {
            function()
                vim.cmd(":Format")
                vim.defer_fn(function() vim.cmd.write() end, 20)
            end,
            desc = "format current buffer or selected",
            mode = { "n", "v" },
        },
        ["t"] = { ":FormatOnSaveToggle<CR>", desc = "toggle format-on-save: ", mode = { "n", "v" } },
    },
})
