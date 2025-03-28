local cmp_state = {
	is_init = false,
	sort = "lsp", -- 'buffer', 'lsp' or 'snippets', 어떤 completion이 로드되었는지 상태를 저장
}
local function show_provider(cmp, sort)
	cmp.show({ providers = { sort } })
	cmp_state.sort = sort
	print(sort)
	return true -- doesn't runs the next command in keymap setting
end

return {
	{
		-- config ref https://cmp.saghen.dev/configuration/reference.html
		"saghen/blink.cmp",
		event = { "InsertEnter" },
		-- optional: provides snippets for the snippet source
		dependencies = { "rafamadriz/friendly-snippets", "onsails/lspkind.nvim" },

		-- use a release tag to download pre-built binaries
		version = "1.*",
		-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				preset = "none",

				-- disable a keymap from the preset
				["<C-e>"] = {
					function(cmp)
						if cmp.is_visible() then
							cmp_state.is_init = false -- 초기화
							cmp.cancel()
							return true
						end
					end,
					"fallback",
				},
				["<C-k>"] = {
					function(cmp)
						if not cmp.is_visible() then
							cmp_state.is_init = true
							return show_provider(cmp, "buffer")
						end
					end,
					"select_prev",
					"fallback",
				},
				["<C-j>"] = {
					function(cmp)
						if not cmp.is_visible() then
							cmp_state.is_init = true
							return show_provider(cmp, "lsp")
						end
					end,
					"select_next",
					"fallback",
				},
				["<A-k>"] = {
					function(cmp)
						if cmp.is_visible() then
							cmp.scroll_documentation_up(2)
							return true
						end
					end,
					"fallback",
				},
				["<A-j>"] = {
					function(cmp)
						if cmp.is_visible() then
							cmp.scroll_documentation_down(2)
							return true
						end
					end,
					"fallback",
				},
				-- control whether the next command will be run when using a function
				["<C-n>"] = {
					function(cmp)
						if not cmp_state.is_init then
							cmp_state.is_init = true
							return show_provider(cmp, "lsp")
						elseif cmp_state.sort == "lsp" then
							return show_provider(cmp, "buffer")
						elseif cmp_state.sort == "buffer" then
							return show_provider(cmp, "lsp")
						end
					end,
					-- DEPRECATED:: 2025-03-28
					-- lsp/buffer/snippets
					-- function(cmp)
					-- 	if not cmp_state.is_init then
					-- 		cmp_state.is_init = true
					-- 		return show_provider(cmp, "lsp")
					-- 	elseif cmp_state.sort == "lsp" then
					-- 		return show_provider(cmp, "buffer")
					-- 	elseif cmp_state.sort == "buffer" then
					-- 		return show_provider(cmp, "snippets")
					-- 	elseif cmp_state.sort == "snippets" then
					-- 		return show_provider(cmp, "lsp")
					-- 	end
					-- end,
					"fallback",
				},
				["<C-p>"] = {
					function(cmp)
						if not cmp_state.is_init then
							cmp_state.is_init = true
							return show_provider(cmp, "buffer")
						elseif cmp_state.sort == "buffer" then
							return show_provider(cmp, "lsp")
						elseif cmp_state.sort == "lsp" then
							return show_provider(cmp, "buffer")
						end
					end,
					-- DEPRECATED:: 2025-03-28
					-- lsp/buffer/snippets
					-- function(cmp)
					-- 	if not cmp_state.is_init then
					-- 		cmp_state.is_init = true
					-- 		return show_provider(cmp, "snippets")
					-- 	elseif cmp_state.sort == "buffer" then
					-- 		return show_provider(cmp, "lsp")
					-- 	elseif cmp_state.sort == "lsp" then
					-- 		return show_provider(cmp, "snippets")
					-- 	elseif cmp_state.sort == "snippets" then
					-- 		return show_provider(cmp, "buffer")
					-- 	end
					-- end,
					"fallback",
				},

				["<Enter>"] = {
					function(cmp)
						if cmp.snippet_active() then
							cmp_state.is_init = false -- 초기화
							return cmp.accept()
						elseif cmp.is_visible() then
							cmp_state.is_init = false -- 초기화
							return cmp.select_and_accept()
						end
					end,
					"fallback",
				},
				["<Tab>"] = {
					function(cmp)
						if cmp.snippet_active() then
							cmp_state.is_init = false -- 초기화
							return cmp.accept()
						elseif cmp.is_visible() then
							return cmp.select_and_accept()
						end
					end,
					"snippet_forward",
					"fallback",
				},

				["<S-Tab>"] = { "snippet_backward", "fallback" },

				["<Esc>"] = {
					function(cmp)
						if cmp.is_visible() then
							cmp_state.is_init = false -- 초기화
							cmp.cancel()
							return true
						end
					end,
					"fallback",
				},
			},

			cmdline = {
				keymap = {
					-- preset = 'enter',
					["<C-space>"] = { "fallback" },
					["<C-n>"] = { "show", "fallback" },
					["<C-e>"] = { "cancel", "fallback" },
					["<C-k>"] = { "select_prev", "fallback" },
					["<C-j>"] = { "select_next", "fallback" },
					["<Tab>"] = { "show", "accept", "fallback" },
					["<Enter>"] = {
						function(cmp)
							return cmp.select_and_accept({
								callback = function()
									vim.api.nvim_feedkeys("\n", "n", true)
								end,
							})
						end,
						"fallback",
					},
					["<A-Enter>"] = {
						function(cmp)
							cmp.cancel()
						end,
						"fallback",
					},
				},
			},

			appearance = {
				-- Sets the fallback highlight groups to nvim-cmp's highlight groups
				-- Useful for when your theme doesn't support blink.cmp
				-- Will be removed in a future release
				use_nvim_cmp_as_default = true,
				-- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			completion = {
				keyword = { range = "full" },
				list = {
					max_items = 15,
					selection = {
						-- preselect = function(ctx) return ctx.mode ~= 'cmdline' end,
						preselect = true,
						-- auto_insert = false
						auto_insert = true,
						-- auto_insert = function(ctx)
						-- 	return ctx.mode == "cmdline"
						-- end,
					},
				},

				-- Disable auto brackets
				-- NOTE: some LSPs may add auto brackets themselves anyway
				accept = { auto_brackets = { enabled = true } },

				menu = {
					enabled = true,
					-- min_width = 15,
					max_height = 7,
					border = "none",
					winblend = 0,
					winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
					-- Keep the cursor X lines away from the top/bottom of the window
					scrolloff = 1,
					-- Note that the gutter will be disabled when border ~= 'none'
					scrollbar = true,
					-- Which directions to show the window,
					-- falling back to the next direction when there's not enough space
					direction_priority = { "s", "n" },

					-- Whether to automatically show the window when new completion items are available
					auto_show = true,

					-- Screen coordinates of the command line
					cmdline_position = function()
						if vim.g.ui_cmdline_pos ~= nil then
							local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
							return { pos[1] - 1, pos[2] }
						end
						local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
						return { vim.o.lines - height, 0 }
					end,

					-- Controls how the completion items are rendered on the popup window
					draw = {
						-- Aligns the keyword you've typed to a component in the menu
						align_to = "label", -- or 'none' to disable, or 'cursor' to align to the cursor
						-- Left and right padding, optionally { left, right } for different padding on each side
						padding = 1,
						-- Gap between columns
						gap = 1,
						-- Use treesitter to highlight the label text for the given list of sources
						treesitter = { "lsp" },

						-- Components to render, grouped by column
						columns = { { "kind_icon" }, { "label", "source_name", gap = 5 } },

						-- Definitions for possible components to render. Each defines:
						--   ellipsis: whether to add an ellipsis when truncating the text
						--   width: control the min, max and fill behavior of the component
						--   text function: will be called for each item
						--   highlight function: will be called only when the line appears on screen
						components = {
							kind_icon = {
								ellipsis = false,
								text = function(ctx)
									local icon = ctx.kind_icon
									if vim.tbl_contains({ "Path" }, ctx.source_name) then
										local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											icon = dev_icon
										end
									else
										icon = require("lspkind").symbolic(ctx.kind, {
											mode = "symbol",
										})
									end

									return icon .. ctx.icon_gap
								end,
							},

							label = {
								width = { fill = true, max = 60 },
								text = function(ctx)
									return ctx.label .. ctx.label_detail
								end,
								highlight = function(ctx)
									-- label and label details
									local highlights = {
										{
											0,
											#ctx.label,
											group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
										},
									}
									if ctx.label_detail then
										table.insert(highlights, {
											#ctx.label,
											#ctx.label + #ctx.label_detail,
											group = "BlinkCmpLabelDetail",
										})
									end

									-- characters matched on the label by the fuzzy matcher
									for _, idx in ipairs(ctx.label_matched_indices) do
										table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
									end

									return highlights
								end,
							},

							label_description = {
								width = { max = 30 },
								text = function(ctx)
									return ctx.label_description
								end,
								highlight = "BlinkCmpLabelDescription",
							},

							source_name = {
								width = { max = 30 },
								text = function(ctx)
									return ctx.source_name
								end,
								highlight = "BlinkCmpSource",
							},
						},
					},
				},

				-- Show documentation when selecting a completion item
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 20,
					window = {
						border = require("utils").borders.documentation,
					},
				},

				-- Display a preview of the selected item on the current line
				--
				-- 이거 괜찮을수도? menu를 manual-mode로 사용하되, 첫번째 제안을 ghost_text로 보여주는 것
				-- 4a380c1 feat(ghost_text): show_on_unselected (#965)
				ghost_text = { enabled = true },
				trigger = {
					-- show_on_keyword = false,
				},
			},

			fuzzy = {
				use_frecency = true, -- Frecency tracks the most recently/frequently used items and boosts the score of the item
				use_proximity = true, -- Proximity bonus boosts the score of items matching nearby words
				sorts = {
					"exact",
					-- defaults
					"score",
					"sort_text",
				},
			},

			snippets = { preset = "default" },

			sources = {
				-- default = { 'lsp', 'path', 'snippets', 'buffer' },
				default = { "lsp", "path" },
				providers = {
					buffer = {
						-- min_keyword_length = 2,
						max_items = 5, -- Maximum number of items to display in the menu
					},
					lsp = {
						-- min_keyword_length = 2,
						max_items = 15, -- Maximum number of items to display in the menu
						timeout_ms = 1,
					},
					snippets = {
						min_keyword_length = 2,
						max_items = 5, -- Maximum number of items to display in the menu
					},
				},
				min_keyword_length = function(ctx)
					if ctx.mode == "cmdline" then
						return 1
					end
					return 1
				end,
				-- no snippets ever
				-- transform_items = function(_, items)
				--   return vim.tbl_filter(function(item)
				--     return item.kind ~= require('blink.cmp.types').CompletionItemKind.Snippet
				--   end, items)
				-- end
			},

			-- Experimental signature help support
			-- https://cmp.saghen.dev/configuration/signature
			signature = {
				enabled = true,
				-- trigger = {
				-- 	show_on_insert = true,
				-- },
				window = {
					border = require("utils").borders.signature,
					winhighlight = "Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder",
					show_documentation = false,
				},
			},
		},
	},
}
