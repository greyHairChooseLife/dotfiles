return {
    "greyhairchooselife/ansi.nvim",
    lazy = false,
    config = function()
        require("ansi").setup({
            auto_enable = false, -- Auto-enable for configured filetypes
            auto_enable_stdin = true, -- Auto-enable for piped stdin content
            filetypes = { "log", "ansi" },
        })
    end,
}
