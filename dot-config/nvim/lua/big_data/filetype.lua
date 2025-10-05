vim.api.nvim_create_autocmd("FileType", {
    pattern = "csv",
    callback = function()
        require("csvview").enable()

        vim.opt_local.mousescroll = "ver:3,hor:6" -- Enable horizontal scroll
        vim.opt_local.wrap = false
    end,
})
