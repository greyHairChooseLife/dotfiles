local wk_map = require("utils").wk_map
wk_map({
    ["<leader>D"] = {
        group = "  DB",
        order = { "t" },
        ["t"] = {
            function()
                vim.cmd("tabnew")
                vim.schedule(function()
                    local tabnr = vim.fn.tabpagenr()
                    vim.fn.settabvar(tabnr, "tabname", "Database")
                    vim.cmd("DBUI")
                end)
            end,
            desc = "tab open DB",
            mode = "n",
        },
    },
})
