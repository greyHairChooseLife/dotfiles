return {
    "neovim/nvim-lspconfig",
    lazy = false,
    event = { "BufReadPre" },
    dependencies = {
        "saghen/blink.cmp",
        {
            "folke/lazydev.nvim",
            opts = {
                library = {
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            },
        },
    },
    config = function()
        local servers = {
            emmylua_ls = { settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
            html = {},
            superhtml = {},
            -- ts_ls = {},
            tsgo = {},
            vtsls = {
                typescript = {
                    inlayHints = {
                        parameterNames = { enabled = "all" },
                        parameterTypes = { enabled = true },
                        variableTypes = { enabled = true },
                        propertyDeclarationTypes = { enabled = true },
                        functionLikeReturnTypes = { enabled = true },
                        enumMemberValues = { enabled = true },
                    },
                },
                javascript = {
                    inlayHints = {
                        parameterNames = { enabled = "all" },
                        parameterTypes = { enabled = true },
                        variableTypes = { enabled = true },
                        propertyDeclarationTypes = { enabled = true },
                        functionLikeReturnTypes = { enabled = true },
                        enumMemberValues = { enabled = true },
                    },
                },
            },
            ruff = { init_options = { settings = { showSyntaxErrors = false } } },
            pylsp = {
                settings = {
                    pylsp = {
                        pyflakes = { enabled = false },
                        pycodestyle = { enabled = false },
                        autopep8 = { enabled = false },
                        yapf = { enabled = false },
                        mccabe = { enabled = false },
                        pylsp_mypy = { enabled = false },
                        pylsp_black = { enabled = false },
                        pylsp_isort = { enabled = false },
                        -- plugins = {
                        -- 	pycodestyle = {
                        -- 		ignore = { "W391" },
                        -- 		maxLineLength = 100,
                        -- 	},
                        -- },
                    },
                },
            },
            biome = {},
            basedpyright = {
                on_init = function(client)
                    local venv = client.root_dir and (client.root_dir .. "/.venv/bin/python")
                    if venv and vim.fn.executable(venv) == 1 then
                        client.config.settings.basedpyright.pythonPath = venv
                    end
                end,
                settings = {
                    basedpyright = {
                        analysis = {
                            autoSearchPaths = true,
                            diagnosticMode = "openFilesOnly",
                            useLibraryCodeForTypes = true,
                            typeCheckingMode = "basic",
                            diagnosticSeverityOverrides = {
                                reportAny = false,
                                reportMissingTypeArgument = false,
                                reportMissingTypeStubs = false,
                                reportUnknownArgumentType = false,
                                reportUnknownMemberType = false,
                                reportUnusedParameter = "warning",
                                reportMissingParameterType = "none",
                                reportUnknownParameterType = false,
                                reportUnknownVariableType = false,
                                reportUnusedCallResult = false,
                                reportUnusedVariable = "warning",
                                reportUnusedImport = "warning",
                                reportOptionalMemberAccess = "warning",
                                reportOptionalSubscript = "warning",
                                reportCallIssue = "warning",
                                reportArgumentType = "warning",
                            },
                        },
                    },
                },
            },
            taplo = {},
            docker_compose_language_service = {}, -- doesn't work at all
            yamlls = {},
            dockerls = {},
            bashls = {},
            clangd = {},
            terraformls = {},
            -- markdown_oxide = {},
            -- marksman = {},
            zk = { workspace_required = false },
            lemminx = {},
            cssvars = {}, -- css-variables-language-server
            cssmodules_ls = {}, -- cssmodules-language-server
            cssls = {}, -- css-lsp
        }
        local disabled_server = {
            "pylsp",
            "ruff", -- lsp 없어도 format은 잘만 된다.
        }

        for server, config in pairs(servers) do
            config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)

            if vim.tbl_contains(disabled_server, server) then
                vim.lsp.enable(server, false)
            else
                vim.lsp.config(server, config)
                vim.lsp.enable(server)
            end
        end

        -- MEMO:: ruff doesn't need to hoverProvider(open doc)
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client == nil then return end
                if client.name == "ruff" then
                    -- Disable hover in favor of Pyright
                    client.server_capabilities.hoverProvider = false
                end
                if client.name == "cssmodules_ls" then client.server_capabilities.hoverProvider = false end
                if client.name == "tsgo-tmp" then
                    local caps = client.server_capabilities

                    -- UX / interaction
                    caps.hoverProvider = false
                    caps.completionProvider = false
                    caps.definitionProvider = false
                    caps.declarationProvider = false
                    caps.implementationProvider = false
                    caps.referencesProvider = false
                    caps.renameProvider = false
                    caps.codeActionProvider = false
                    caps.signatureHelpProvider = false
                    caps.documentHighlightProvider = false

                    -- symbols / navegation
                    caps.documentSymbolProvider = false
                    caps.workspaceSymbolProvider = false

                    -- format / tokens
                    caps.documentFormattingProvider = false
                    caps.documentRangeFormattingProvider = false
                    caps.semanticTokensProvider = nil

                    -- other
                    caps.typeDefinitionProvider = false
                    caps.callHierarchyProvider = false
                    caps.selectionRangeProvider = false
                    caps.inlayHintProvider = false

                    -- diagnostics: no touch
                    -- textDocument/publishDiagnostics don't depend on capabilities
                end
            end,
            desc = "LSP: Disable hover capability from Ruff",
        })
    end,
}

-- return {
--   "neovim/nvim-lspconfig",
--   config = function()
--     local nvim_lsp = require("lspconfig")
--
--     vim.api.nvim_command("inoremap <C-n> <C-x><C-o>")
--
--     -- Set up lspconfig.
--     local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
--
--     local servers = {
--       "bashls",
--       "cssls",
--       "dockerls",
--       "eslint",
--       "gopls",
--       "html",
--       "intelephense",
--       "jsonls",
--       "lua_ls",
--       "pyright",
--       "rust_analyzer",
--       "sqlls",
--       "svelte",
--       "tailwindcss",
--       "terraformls",
--       "ts_ls",
--       "vimls",
--       "yamlls",
--     }
--
--     for _, lsp in ipairs(servers) do
--       if nvim_lsp[lsp] ~= nil then
--         if nvim_lsp[lsp].setup ~= nil then
--           nvim_lsp[lsp].setup({
--             capabilities = capabilities,
--           })
--         else
--           vim.notify("LSP server " .. lsp .. " does not have a setup function", vim.log.levels.ERROR)
--         end
--       end
--     end
--
--     local eslint_linter = require("config.linters.eslint")
--     local shellcheck_linter = require("config.linters.shellcheck")
--
--     nvim_lsp.diagnosticls.setup({
--       filetypes = {
--         "javascript",
--         "javascript.jsx",
--         "sh",
--         "typescript",
--       },
--       init_options = {
--         filetypes = {
--           ["javascript.jsx"] = "eslint",
--           javascript = "eslint",
--           javascriptreact = "eslint",
--           sh = "shellcheck",
--           typescript = "eslint",
--           typescriptreact = "eslint",
--         },
--         linters = {
--           eslint = eslint_linter,
--           shellcheck = shellcheck_linter,
--         },
--       },
--     })
--   end,
-- }
