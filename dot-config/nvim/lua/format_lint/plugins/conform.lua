return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua", stop_after_first = true },
                http = { "kulala" },
                html = { "superhtml", stop_after_first = true },
                css = { "biome" },
                javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
                typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
                javascriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
                typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
                json = { "prettierd", stop_after_first = true },
                python = {
                    "ruff_organize_imports",
                    "ruff_fix", -- 사용않는 import 등
                    "ruff_format",
                },
                bash = { "shfmt", stop_after_first = true },
                sh = { "shfmt", stop_after_first = true },
                yaml = { "prettierd", "prettier" },
                -- yaml = { "yamlfmt" },
                toml = { "taplo" },
                c = { "clang-format" },
                terraform = { "terraform" },
            },
            formatters = {
                kulala = {
                    command = "kulala-fmt",
                    args = { "format", "$FILENAME" },
                    stdin = false,
                },
                biome = { require_cwd = true },
                shfmt = { args = { "-i=4", "-ci", "-bn", "-sr", "-kp" } },
                terraform = {
                    command = "terraform",
                    args = { "fmt", "-" },
                },
                yamlfmt = {}, -- $HOME/.config/yamlfmt/.yamlfmt.yml
                -- ruff_organize_imports = {
                -- 	args = { "order-by-type = false" },
                ["clang-format"] = {
                    -- ref:
                    -- https://www.youtube.com/watch?v=upeAH74q0q4&t=61s
                    -- https://github.com/ProgrammingRainbow/NvChad-2.5?tab=readme-ov-file#conform
                    -- https://clang.llvm.org/docs/ClangFormatStyleOptions.html
                    prepend_args = { "--style=file", "--fallback-style=Chromium" },
                    -- prepend_args = {
                    --     "-style={ \
                    --       IndentWidth: 4, \
                    --       TabWidth: 4, \
                    --       UseTab: Never, \
                    --       AccessModifierOffset: 0, \
                    --       IndentAccessModifiers: true, \
                    --       PackConstructorInitializers: Never \
                    --     }",
                    -- },
                }, -- },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        })
    end,
    keys = {
        -- {
        -- 	"<leader>rf",
        -- 	function()
        -- 		local bufnr = vim.api.nvim_get_current_buf()
        -- 		local filetype = vim.bo[bufnr].filetype
        -- 		local formatters = require("conform").list_formatters_for_buffer(bufnr)

        -- 		local formatted = require("conform").format({
        -- 			bufnr = bufnr,
        -- 			lsp_fallback = true,
        -- 			async = false,
        -- 		})

        -- 		vim.notify("Filetype: " .. filetype)
        -- 		vim.notify("Available formatters: " .. vim.inspect(formatters))
        -- 		vim.notify("Formatting result: " .. tostring(formatted))
        -- 	end,
        -- 	desc = "Format with debug info",
        -- },
    },
}
