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
      lua_ls = {},
      html = {},
      superhtml = {},
      ts_ls = {},
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
        if client == nil then
          return
        end
        if client.name == "ruff" then
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false
        end
      end,
      desc = "LSP: Disable hover capability from Ruff",
    })
  end,
}
