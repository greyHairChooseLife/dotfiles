return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"ts_ls",
				},
			})
		end,
	},

	{
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
		opts = {
			servers = {
				lua_ls = {},
				ts_ls = {},
			},
		},
		config = function(_, opts)
			local lspconfig = require("lspconfig")
			for server, config in pairs(opts.servers) do
				config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
				lspconfig[server].setup(config)
			end
		end,
	},

	-- --nvim-cmp with sources
	-- {
	-- 	"hrsh7th/nvim-cmp",
	--    enabled = false,
	--    event = {"InsertEnter"},
	--    dependencies = {
	--      {
	--        "hrsh7th/cmp-buffer",
	--        "hrsh7th/cmp-path",
	--        "hrsh7th/cmp-cmdline",
	--        "hrsh7th/cmp-nvim-lsp",
	--        { "L3MON4D3/LuaSnip", tag = "v2.*", run = "make install_jsregexp" },
	--        "saadparwaiz1/cmp_luasnip",
	--        "rafamadriz/friendly-snippets",
	--        "windwp/nvim-autopairs",
	--        config = function()
	--          require("nvim-autopairs").setup()
	--
	--          --nvim-cmp
	--          require("luasnip.loaders.from_vscode").lazy_load()
	--          local luasnip = require("luasnip")
	--
	--          local has_words_before = function()
	--            unpack = unpack or table.unpack
	--            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	--            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
	--          end
	--          -- START_debug:
	--          local function pp(t) -- print_value_or_keys_if_table
	--            if type(t) ~= "table" then
	--              print("value: ", t)
	--              return
	--            end
	--            local keys = {}
	--            for k in pairs(t) do
	--              table.insert(keys, k)
	--            end
	--            print(table.concat(keys, ", "))
	--          end
	--          -- END___debug:
	--
	--          local cmp = require("cmp")
	--          local state = {
	--            sort = "buf", -- 'buf', 'lsp' or 'snip', 어떤 completion이 로드되었는지 상태를 저장
	--            is_loading = false, -- completion이 로드되었는지 상태를 저장
	--          }
	--
	--          cmp.setup({
	--            snippet = {
	--              -- REQUIRED - you must specify a snippet engine
	--              expand = function(args)
	--                luasnip.lsp_expand(args.body) -- For `luasnip` users.
	--              end,
	--            },
	--
	--            window = {
	--              completion = { side_padding = 1 },
	--              documentation = {
	--                -- border = { "", "", "", "", "", "", "", "▊" },
	--                border = {
	--                  "▊",
	--                  " ",
	--                  " ",
	--                  " ",
	--                  " ",
	--                  " ",
	--                  "▊",
	--                  "▊",
	--                },
	--
	--                focusable = true,
	--                winhighlight = "FloatBorder:CmpDocBorder",
	--                max_width = 120,
	--                max_height = 50,
	--              },
	--            },
	--
	--            completion = {
	--              keyword_length = 2, -- 입력한 글자수 이상부터 completion이 작동
	--            },
	--
	--            matching = {
	--              -- disallow_fuzzy_matching = true, -- 일단 제외해서 단순하게 유지하고, 필요하다고 느끼면 추가해주자
	--              disallow_partial_matching = false,
	--              disallow_prefix_unmatching = true,
	--            },
	--
	--            mapping = cmp.mapping.preset.insert({
	--              ["<A-j>"] = cmp.mapping.scroll_docs(2),
	--              ["<A-k>"] = cmp.mapping.scroll_docs(-2),
	--              -- ['<C-l>'] = cmp.mapping.complete(), -- cmp창 강제 열기
	--              ["<C-e>"] = cmp.mapping.abort(),
	--              ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	--              ["<TAB>"] = cmp.mapping(function(fallback)
	--                if cmp.visible() then
	--                  cmp.confirm({ select = true })
	--                else
	--                  fallback()
	--                end
	--              end, { "i", "s", "c" }),
	--              --  START_debug:
	--              -- ["<C-;>"] = cmp.mapping(function(fallback)
	--              -- 	local sel = cmp.get_selected_entry()
	--              --
	--              -- 	if sel then
	--              -- 		print("sel:")
	--              -- 		pp(sel.source)
	--              --
	--              -- 		print("sel.source.kind:")
	--              -- 		pp(sel.source.source)
	--              -- 		pp(sel.source.context)
	--              -- 	end
	--              -- end, { "i", "c" }),
	--              -- END___debug:
	--
	--              ["<C-j>"] = cmp.mapping(function(fallback)
	--                if cmp.visible() then
	--                  -- cmp.select_next_item({ behavior = cmp.SelectBehavior.Select }) -- 선택은 하지만 완성은 안시킨다.
	--                  cmp.select_next_item()
	--                elseif luasnip.expand_or_jumpable() then
	--                  luasnip.expand_or_jump()
	--                else
	--                  fallback()
	--                end
	--              end, { "i", "c" }),
	--
	--              ["<C-k>"] = cmp.mapping(function(fallback)
	--                if cmp.visible() then
	--                  -- cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select }) -- 선택은 하지만 완성은 안시킨다.
	--                  cmp.select_prev_item()
	--                elseif luasnip.jumpable(-1) then
	--                  luasnip.jump(-1)
	--                else
	--                  fallback()
	--                end
	--              end, { "i", "c" }),
	--
	--              ["<C-n>"] = cmp.mapping(function(fallback)
	--                if has_words_before() and state.sort == "buf" then
	--                  cmp.abort()
	--                  state.sort = "lsp"
	--                  cmp.complete({
	--                    config = {
	--                      sources = {
	--                        {
	--                          name = "nvim_lsp",
	--                          max_item_count = 15,
	--                          entry_filter = function(entry, ctx)
	--                            return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Snippet"
	--                          end,
	--                        },
	--                      },
	--                    },
	--                  })
	--                  return
	--                end
	--                if has_words_before() and state.sort == "lsp" then
	--                  state.sort = "snip"
	--                  cmp.complete({
	--                    config = {
	--                      sources = {
	--                        { name = "luasnip", max_item_count = 15, keyword_length = 3 },
	--                      },
	--                    },
	--                  })
	--                  return
	--                end
	--                if has_words_before() and state.sort == "snip" then
	--                  state.sort = "buf"
	--                  cmp.complete({
	--                    config = {
	--                      sources = {
	--                        { name = "buffer" },
	--                        { name = "path" },
	--                      },
	--                    },
	--                  })
	--                  return
	--                end
	--
	--                fallback()
	--              end, { "i", "s" }),
	--
	--              ["<C-p>"] = cmp.mapping(function(fallback)
	--                if has_words_before() and state.sort == "snip" then
	--                  state.sort = "lsp"
	--                  cmp.complete({
	--                    config = {
	--                      sources = {
	--                        {
	--                          name = "nvim_lsp",
	--                          max_item_count = 15,
	--                          entry_filter = function(entry, ctx)
	--                            return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Snippet"
	--                          end,
	--                        },
	--                      },
	--                    },
	--                  })
	--                  return
	--                end
	--                if has_words_before() and state.sort == "lsp" then
	--                  state.sort = "buf"
	--                  cmp.complete({
	--                    config = {
	--                      sources = {
	--                        { name = "buffer" },
	--                        { name = "path" },
	--                      },
	--                    },
	--                  })
	--                  return
	--                end
	--                if has_words_before() and state.sort == "buf" then
	--                  state.sort = "snip"
	--                  cmp.complete({
	--                    config = {
	--                      sources = {
	--                        { name = "luasnip", max_item_count = 15, keyword_length = 3 },
	--                      },
	--                    },
	--                  })
	--                  return
	--                end
	--
	--                fallback()
	--              end, { "i", "s" }),
	--
	--              ["<C-b>"] = cmp.mapping(function(fallback)
	--                if state.is_loading and state.sort == "buf" then
	--                  return
	--                end
	--                if has_words_before() and state.sort ~= "buf" then
	--                  cmp.abort()
	--                  state.is_loading = true
	--                  state.sort = "buf"
	--                  cmp.complete({
	--                    config = {
	--                      sources = {
	--                        { name = "buffer" },
	--                        { name = "path" },
	--                      },
	--                    },
	--                  })
	--                  cmp.event:on("menu_opened", function()
	--                    state.is_loading = false
	--                  end)
	--                  return
	--                end
	--
	--                fallback()
	--              end, { "i", "s" }),
	--              ["<C-l>"] = cmp.mapping(function(fallback)
	--                if state.is_loading and state.sort == "lsp" then
	--                  return
	--                end
	--                if has_words_before() and state.sort ~= "lsp" then
	--                  cmp.abort()
	--                  state.is_loading = true
	--                  state.sort = "lsp"
	--                  cmp.complete({
	--                    config = {
	--                      sources = {
	--                        {
	--                          name = "nvim_lsp",
	--                          max_item_count = 15,
	--                          entry_filter = function(entry)
	--                            return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Snippet"
	--                          end,
	--                        },
	--                      },
	--                    },
	--                  })
	--                  cmp.event:on("menu_opened", function()
	--                    state.is_loading = false
	--                  end)
	--                  return
	--                end
	--
	--                fallback()
	--              end, { "i", "s" }),
	--              ["<C-s>"] = cmp.mapping(function(fallback)
	--                if state.is_loading and state.sort == "snip" then
	--                  return
	--                end
	--                if has_words_before() and state.sort ~= "snip" then
	--                  cmp.abort()
	--                  state.is_loading = true
	--                  state.sort = "snip"
	--                  cmp.complete({
	--                    config = {
	--                      sources = {
	--                        { name = "luasnip", max_item_count = 15, keyword_length = 3 },
	--                      },
	--                    },
	--                  })
	--                  cmp.event:on("menu_opened", function()
	--                    state.is_loading = false
	--                  end)
	--                  return
	--                end
	--
	--                fallback()
	--              end, { "i", "s" }),
	--            }),
	--            sources = cmp.config.sources(
	--              -- {
	--              -- 	{
	--              -- 		name = "nvim_lsp",
	--              -- 		max_item_count = 15,
	--              -- 		entry_filter = function(entry)
	--              -- 			return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Snippet"
	--              -- 		end,
	--              -- 	},
	--              -- } -- lsp
	--              { { name = "buffer" } } -- text within current buffer
	--              -- { { name = "path" } } -- file system paths
	--              -- { name = "luasnip", max_item_count = 15 }, -- 우선적으로 로드
	--            ),
	--          })
	--
	--          -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
	--          cmp.setup.cmdline({ "/", "?" }, {
	--            -- mapping = cmp.mapping.preset.cmdline(),
	--            sources = {
	--              { name = "buffer" },
	--              -- { name = "path" },
	--            },
	--          })
	--
	--          -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
	--          cmp.setup.cmdline(":", {
	--            completion = {
	--              keyword_length = 1, -- 입력한 글자수 이상부터 completion이 작동
	--            },
	--            matching = {},
	--            performance = { max_view_entries = 10 },
	--            -- mapping = cmp.mapping.preset.cmdline(),
	--            sources = cmp.config.sources({
	--              { name = "path" },
	--            }, {
	--              { name = "cmdline" },
	--            }),
	--          })
	--
	--          local cmp_autopairs = require("nvim-autopairs.completion.cmp")
	--          cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	--        end,
	--      }
	-- 	},
	-- },
	--
	--
	-- -- --nvim-cmp with sources
	-- -- use({ "hrsh7th/cmp-buffer" })
	-- -- use({ "hrsh7th/cmp-path" })
	-- -- use({ "hrsh7th/cmp-cmdline" })
	-- -- use({ "hrsh7th/cmp-nvim-lsp" })
	-- -- use({ "L3MON4D3/LuaSnip", tag = "v2.*", run = "make install_jsregexp" })
	-- -- use({ "saadparwaiz1/cmp_luasnip" })
	-- -- use({ "rafamadriz/friendly-snippets" })
	-- -- use({
	-- -- 	"hrsh7th/nvim-cmp",
	-- -- 	requires = {
	-- -- 		"windwp/nvim-autopairs",
	-- -- 		config = function()
	-- -- 			require("nvim-autopairs").setup()
	-- -- 		end,
	-- -- 	},
	-- -- })
}
