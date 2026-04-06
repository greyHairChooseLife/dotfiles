return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    cmd = "Conform",
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
                sh = { "beautysh", "shfmt", stop_after_first = true },
                zsh = { "beautysh", "shfmt", stop_after_first = true }, -- 일부 zsh 문법에는 대응하지 못한다.
                yaml = { "yamlfmt", "prettierd", "prettier", stop_after_first = true },
                toml = { "taplo" },
                c = { "clang-format" },
                terraform = { "terraform" },
                xml = { "xmlformat" },
                hpf = { "xmlformat" },
                rdf = { "xmlformat" },
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
    vim.api.nvim_create_user_command("Format", function(args)
        local bufnr = vim.api.nvim_get_current_buf()
        local filetype = vim.bo[bufnr].filetype

        -- 마크다운 range 포맷: prettierd는 range를 지원하지 않으므로 임시 버퍼 사용
        if filetype == "markdown" and args.range ~= 0 then
            local lines = vim.api.nvim_buf_get_lines(bufnr, args.line1 - 1, args.line2, false)
            local tmp = vim.api.nvim_create_buf(false, true)
            vim.bo[tmp].filetype = "markdown"
            vim.api.nvim_buf_set_lines(tmp, 0, -1, false, lines)

            require("conform").format({ bufnr = tmp, formatters = { "prettierd" }, async = false }, function(err)
                if err then
                    vim.notify("Format error: " .. err, vim.log.levels.ERROR)
                    vim.api.nvim_buf_delete(tmp, { force = true })
                    return
                end
                local formatted = vim.api.nvim_buf_get_lines(tmp, 0, -1, false)
                vim.api.nvim_buf_set_lines(bufnr, args.line1 - 1, args.line2, false, formatted)
                vim.api.nvim_buf_delete(tmp, { force = true })
            end)
            return
        end

        local range = nil
        if args.range ~= 0 then
            local end_line_content = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1] or ""
            range = {
                start = { args.line1, 0 },
                ["end"] = { args.line2, end_line_content:len() },
            }
        end

        require("conform").format({
            async = true,
            lsp_format = "fallback",
            range = range,
        })
    end, { range = true }),
    keys = {},
}
