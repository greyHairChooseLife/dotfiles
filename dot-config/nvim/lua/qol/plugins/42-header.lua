-- https://github.com/Diogo-ss/42-header.nvim
return {
    "Diogo-ss/42-header.nvim",
    cmd = { "Stdheader" },
    -- lazy = false, -- BufWritePre autocmd must exist before the first save
    config = function()
        -- The plugin resolves vim.g.user / vim.g.mail before its own opts,
        -- so these globals keep the 42 identity despite $USER = "sy".
        vim.g.user = "sangkim"
        vim.g.mail = "sangkim@student.42gyeongsan.kr"

        require("42header").setup({
            default_map = false, -- no keymap; insert only with :Stdheader
            auto_update = true, -- refresh the Updated line on save, never create
        })
    end,
}
