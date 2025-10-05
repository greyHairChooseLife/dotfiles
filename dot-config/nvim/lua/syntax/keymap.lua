local wk_map = require("utils").wk_map

-- MEMO:: (Syntax) Tree
wk_map({
    ["<Space>t"] = {
        group = "Tree       - Aerial",
        order = { "f", "t" },
        ["f"] = {
            function()
                vim.cmd("norm ^ww")
                vim.cmd("AerialOpen")
            end,
            desc = "focus",
            mode = "n",
        },
        ["t"] = {
            function()
                vim.cmd("AerialToggle")
                vim.cmd("wincmd p")
            end,
            desc = "toggle ",
            mode = "n",
        },
    },
})
