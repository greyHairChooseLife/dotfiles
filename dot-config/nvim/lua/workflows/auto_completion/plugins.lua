local bf = require("workflows.auto_completion.function.blink-function")

return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		event = { "InsertEnter" },
		dependencies = { "onsails/lspkind.nvim" },

		opts = {
			keymap = {
				preset = "none",
				["<C-e>"] = {
					function(cmp)
						return bf.cancel(cmp)
					end,
					"fallback",
				},
				["<Esc>"] = {
					function(cmp)
						bf.hide(cmp)
					end,
					"fallback",
				},
				["<C-k>"] = {
					function(cmp)
						return bf.show(cmp, "buffer", true)
					end,
					"select_prev",
					"fallback",
				},
				["<C-j>"] = {
					function(cmp)
						return bf.show(cmp, "lsp", true)
					end,
					"select_next",
					"fallback",
				},
				["<A-o>"] = {
					function(cmp)
						return bf.toggle_documentation(cmp)
					end,
					"show_signature",
					"hide_signature",
					"fallback",
				},
				["<A-k>"] = {
					function(cmp)
						if cmp.is_documentation_visible() then
							return cmp.scroll_documentation_up(2)
						else
							return bf.toggle_documentation(cmp)
						end
					end,
					"fallback",
				},
				["<A-j>"] = {
					function(cmp)
						if cmp.is_documentation_visible() then
							return cmp.scroll_documentation_down(2)
						else
							return bf.toggle_documentation(cmp)
						end
					end,
					"fallback",
				},
				-- control whether the next command will be run when using a function
				["<C-n>"] = {
					function(cmp)
						return bf.next_provider(cmp)
					end,
					"fallback",
				},
				["<C-p>"] = {
					function(cmp)
						return bf.prev_provider(cmp)
					end,
					"fallback",
				},
				["<Enter>"] = {
					function(cmp)
						return bf.accept_and_enter(cmp)
					end,
					"snippet_forward",
					"fallback",
				},
				["<Tab>"] = {
					function(cmp)
						return bf.super_tab(cmp)
					end,
					"snippet_forward",
					"fallback",
				},
				["<S-Tab>"] = { "snippet_backward", "fallback" },
			},

			cmdline = {
				keymap = {
					-- preset = 'enter',
					["<C-space>"] = { "fallback" },
					-- ["<C-n>"] = { "show", "fallback" },
					["<C-e>"] = { "cancel", "fallback" },
					["<C-k>"] = { "select_prev", "fallback" },
					["<C-j>"] = { "select_next", "fallback" },
					["<Tab>"] = { "show", "accept", "fallback" },
					["<Enter>"] = { "select_accept_and_enter", "fallback" },
					["<A-Enter>"] = {
						function(cmp)
							cmp.cancel()
						end,
						"fallback",
					},
				},
				completion = {
					menu = {
						auto_show = function()
							return vim.fn.getcmdtype() == ":" -- Only for command mode, not search
						end,
					},
					ghost_text = { enabled = false },
				},
			},

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			completion = {
				menu = {
					-- auto_show = false,
					auto_show = function()
						return vim.bo.filetype == "codecompanion" and true or false
					end,
					-- min_width = 15,
					max_height = 7,
					border = "none",
					winblend = 0,
					winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
					-- Keep the cursor X lines away from the top/bottom of the window
					scrolloff = 1,
					-- Note that the gutter will be disabled when border ~= 'none'
					scrollbar = true,
					direction_priority = { "s", "n" },
					cmdline_position = function()
						if vim.g.ui_cmdline_pos ~= nil then
							local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
							return { pos[1] - 1, pos[2] }
						end
						local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
						return { vim.o.lines - height, 0 }
					end,
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
				documentation = {
					auto_show = false,
					auto_show_delay_ms = 20,
					window = {
						border = require("utils").borders.documentation,
					},
				},
				keyword = { range = "prefix" },
				list = {
					max_items = 25,
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
				-- NOTE: some LSPs may add auto brackets themselves anyway
				accept = { auto_brackets = { enabled = true } },
				ghost_text = { enabled = false },
			},
			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			sources = {
				default = { "lsp", "path", "codecompanion" },
				min_keyword_length = function()
					return vim.bo.filetype == "markdown" and 2 or 0
				end,
				providers = {
					path = {
						opts = {
							get_cwd = function(_)
								return vim.fn.getcwd()
							end,
						},
					},
					buffer = {
						max_items = 5, -- Maximum number of items to display in the menu
						opts = {
							-- -- get all buffers, even ones like neo-tree
							-- get_bufnrs = vim.api.nvim_list_bufs
							-- or (RECOMMENDED) filter to only "normal" buffers
							get_bufnrs = function()
								return vim.tbl_filter(function(bufnr)
									return vim.bo[bufnr].buftype == ""
								end, vim.api.nvim_list_bufs())
							end,
						},
					},
					lsp = {
						-- min_keyword_length = 2,
						-- max_items = 15, -- Maximum number of items to display in the menu
					},
					cmdline = {
						-- ignores cmdline completions when executing shell commands
						enabled = function()
							return vim.fn.getcmdtype() ~= ":" or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
						end,
					},
				},
				per_filetype = {
					codecompanion = { "codecompanion" },
				},
			},
			fuzzy = {
				implementation = "prefer_rust_with_warning",
				use_frecency = true, -- Frecency tracks the most recently/frequently used items and boosts the score of the item
				use_proximity = true, -- Proximity bonus boosts the score of items matching nearby words
				sorts = {
					"exact",
					-- defaults
					"score",
					"sort_text",
				},
			},

			signature = {
				enabled = true,
				trigger = {
					-- Show the signature help automatically
					enabled = true,
					-- Show the signature help window after typing a trigger character
					show_on_trigger_character = false,
					-- Show the signature help window when entering insert mode
					show_on_insert = false,
					-- Show the signature help window when the cursor comes after a trigger character when entering insert mode
					show_on_insert_on_trigger_character = false,
				},
				window = {
					border = require("utils").borders.signature,
					winhighlight = "Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder",
					show_documentation = true,
				},
			},
		},
		opts_extend = { "sources.default" },
	},
}
