return {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    version = "*",
    opts = {
        size = 100,
        -- open_mapping = [[<c-\>]],
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_filetypes = {},
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        persist_size = false,
        direction = "vertical",
        close_on_exit = true, -- close the terminal window when the process exits
        shell = vim.o.shell, -- change the default shell
        highlights = {
            NormalFloat = {
                -- guifg = "<VALUE-HERE>",
                guibg = "black",
            },
            FloatBorder = {
                -- guifg = "#24283b",
                -- guibg = "#24283b",
                guifg = "black",
                guibg = "black",
            },
        },
        float_opts = {
            border = "none",
            -- width = 150,
            -- height = 50,
            -- row = 5,
            winblend = 0,
            title_pos = "center",
        },
    },
}
