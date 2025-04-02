return {
	{
		-- The plugin location on GitHub
		"vimwiki/vimwiki",
		-- The event that triggers the plugin
		lazy = false,
		event = "BufEnter *.md",
		cmd = "VimwikiIndex",
		-- The configuration for the plugin
		init = function()
			vim.g.vimwiki_global_ext = 0 -- 문제 해결: vimwiki 설정이 markdown 설정을 침투하지 않게 하기

			vim.g.vimwiki_list = {
				{
					path = "~/Documents/dev-wiki/notes/",
					-- path_html = "~/Documents/vimwiki/",
					syntax = "markdown",
					ext = ".md",
					links_space_char = "_", -- link에 띄어쓰기를 알아서 '_'로 바꿔줌
				},
				{
					path = "~/Documents/job-wiki/notes/",
					syntax = "markdown",
					ext = ".md",
					links_space_char = "_",
				},
			}

			vim.g.vimwiki_key_mappings = {
				global = 0,
				lists = 0,
				links = 0,
				table_format = 0,
			}

			vim.g.vimwiki_create_link = 0

			-- MEMO:: 모르겠다, 왜 lua로 안바꿔지냐?
			-- 함수를 전역으로 등록
			_G.vimwiki_fold_level_custom = function(lnum)
				local prev_line = vim.fn.getline(lnum - 1) -- 헤더라인은 살려야지
				local curr_line = vim.fn.getline(lnum)
				local next_line = vim.fn.getline(lnum + 1)
				local next2_line = vim.fn.getline(lnum + 2)
				local last_line = vim.fn.line("$")

				local is_lv2_header = string.match(prev_line, "^##%s")
				local is_lv3_header = string.match(prev_line, "^###%s")
				local is_lv4_header = string.match(prev_line, "^####%s")
				local is_lv5_header = string.match(prev_line, "^#####%s")

				if is_lv2_header then
					return "1"
				end
				if is_lv3_header then
					return "2"
				end
				if is_lv4_header then
					return "3"
				end
				if is_lv5_header then
					return "4"
				end
				if string.match(curr_line, "^%s*$") and string.match(next_line, "^###%s") then
					return "1"
				end
				if string.match(curr_line, "^%s*$") and string.match(next_line, "^####%s") then
					return "2"
				end
				if string.match(curr_line, "^%s*$") and string.match(next_line, "^#####%s") then
					return "3"
				end
				-- if curr_line == last_line or string.match(curr_line, "^%s*$") and string.match(next2_line, "^##%s") then
				if curr_line == last_line or string.match(curr_line, "^%s*$") and string.match(next_line, "^##%s") then
					return "0"
				end

				-- 무엇에도 해당하지 않는 경우 prev_line의 foldlevel을 그대로 사용
				return "="
			end

			-- Vimwiki의 폴딩 방식을 'custom'으로 설정
			vim.g.vimwiki_folding = "custom"

			-- autocmd를 Lua 방식으로 설정
			vim.api.nvim_create_augroup("VimwikiFoldingGroup", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = "VimwikiFoldingGroup",
				pattern = "vimwiki",
				callback = function()
					vim.opt_local.foldmethod = "expr"
					vim.opt_local.foldenable = true
					vim.opt_local.foldmethod = "expr"
					vim.opt_local.foldenable = true
					-- vim.opt_local.foldexpr = "v:lua.vimwiki_fold_level_custom(v:lnum)"
					vim.opt_local.foldexpr =
						"v:lua.require'workflows.UI.folding_styles'.markdown_fold_level_custom(v:lnum)"
					vim.opt_local.foldtext =
						"v:lua.require'workflows.UI.folding_styles'.markdown_fold(v:foldstart, v:foldend, v:foldlevel)"
				end,
			})

			vim.api.nvim_create_augroup("MarkdownFoldingGroup", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = "MarkdownFoldingGroup",
				pattern = "markdown",
				callback = function()
					vim.opt_local.foldmethod = "expr"
					vim.opt_local.foldenable = true
					vim.opt_local.foldmethod = "expr"
					vim.opt_local.foldenable = true
					-- vim.opt_local.foldexpr = "v:lua.vimwiki_fold_level_custom(v:lnum)"
					vim.opt_local.foldexpr =
						"v:lua.require'workflows.UI.folding_styles'.markdown_fold_level_custom(v:lnum)"
					vim.opt_local.foldtext =
						"v:lua.require'workflows.UI.folding_styles'.markdown_fold(v:foldstart, v:foldend, v:foldlevel)"
				end,
			})

			-- TODO: 편의기능 개선
			-- 또한, 이외에도 static file의 주소를 가져온 뒤 손쉽게 하이퍼링크를 만들어주는 것도 해주자. 그림파일인지는 확장자를 통해 판단하면 되니 모든 종류의 스태틱 파일에 동일한 커맨드를 사용가능할듯.
		end,
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		-- lazy = false,
		-- BUG:: 이후 버전 고르면 `[-]` 이거 제대로 렌더링 안된다. `[-] `처럼 공백 있어야만 렌더링 됨.
		-- 곧 업데이트 될텐데, 그때 가서 바꾸자.
		-- commit = "5cec1bb5fb11079a88fd5b3abd9c94867aec5945",
		-- event = "BufEnter *.md",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
		ft = { "markdown", "vimwiki", "Avante", "AvanteInput", "copilot-chat", "gitcommit" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			-- Whether Markdown should be rendered by default or not
			enabled = true,
			-- Filetypes this plugin will run on
			file_types = { "markdown", "vimwiki", "Avante", "AvanteInput", "copilot-chat", "gitcommit" },
			-- Maximum file size (in MB) that this plugin will attempt to render
			-- Any file larger than this will effectively be ignored
			max_file_size = 1.5,
			-- Milliseconds that must pass before updating marks, updates occur
			-- within the context of the visible window, not the entire buffer
			debounce = 30,
			-- The level of logs to write to file: vim.fn.stdpath('state') .. '/render-markdown.log'
			-- Only intended to be used for plugin development / debugging
			log_level = "error",
			-- Vim modes that will show a rendered view of the markdown file
			-- All other modes will be uneffected by this plugin
			render_modes = { "n", "c", "i" },
			on = {
				-- Called when plugin initially attaches to a buffer.
				attach = function() end,
				-- Called after plugin renders a buffer.
				render = function() end,
				-- Called after plugin clears a buffer.
				clear = function() end,
			},
			-- Set to avoid seeing warnings for conflicts in health check
			acknowledge_conflicts = false,
			anti_conceal = {
				-- This enables hiding any added text on the line the cursor is on
				-- This does have a performance penalty as we must listen to the 'CursorMoved' event
				enabled = false,
			},
			-- completions = { blink = { enabled = true } },
			padding = {
				-- Highlight to use when adding whitespace, should match background.
				highlight = "NoteBackground",
			},
			paragraph = {
				enabled = false,
				-- left_margin = 2,
				-- min_width = 20,
			},
			indent = {
				-- 왠진 몰라도 켜면 들여쓰기 되지도 않으면서 테이블 UI 깨지는 버그만 있음
				enabled = true,
				-- Amount of additional padding added for each heading level
				per_level = 3,
				skip_level = 2,
				skip_heading = true,
				icon = " ",
			},
			latex = {
				-- Whether LaTeX should be rendered, mainly used for health check
				enabled = false, -- 안쓸껄?
				-- Executable used to convert latex formula to rendered unicode
				converter = "latex2text",
				-- Highlight for LaTeX blocks
				highlight = "RenderMarkdownMath",
				-- Amount of empty lines above LaTeX blocks
				top_pad = 0,
				-- Amount of empty lines below LaTeX blocks
				bottom_pad = 0,
			},
			heading = {
				-- Turn on / off heading icon & background rendering
				enabled = true,
				atx = true, -- ATX 제목(#으로 시작하는) 렌더링 제어
				setext = false, -- Setext 제목(=== 또는 --- 밑줄이 있는) 렌더링 비활성화
				-- border = { false, true, true, false, false },
				-- border = { false, true, false },
				border = { false },
				border_virtual = true,
				border_prefix = false,
				above = "", -- ▂
				-- Used below heading for border
				below = "█", -- ▔
				-- ▁▂▃▅ (U+2581) Lower One Eighth Block
				-- Determines how the icon fills the available space:
				-- | right   | '#'s are concealed and icon is appended to right side                          |
				-- | inline  | '#'s are concealed and icon is inlined on left side                            |
				-- | overlay | icon is left padded with spaces and inserted on left hiding any additional '#' |
				position = "overlay",
				-- Replaces '#+' of 'atx_h._marker'
				-- The number of '#' in the heading determines the 'level'
				-- The 'level' is used to index into the array using a cycle
				-- icons = { '󰲡 ', '󰲣', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' }, 󰨑
				-- icons = { ' 󰑣 ', ' 󰬺 ', '   󰬻 ', '     󰬼 ', '     ##### ', '       ###### ' },
				-- icons = { ' ', '    ', '      ', '         ', '     ##### ', '       ###### ' },
				-- icons = {
				-- 	"",
				-- 	"",
				-- 	"",
				-- 	" ",
				-- 	" ",
				-- 	" ",
				-- },
				-- icons = function(sections)
				-- 	return table.concat(sections, ".") .. ". "
				-- end,
				icons = function(ctx)
					local sections = ctx.sections
					table.remove(sections, 1)
					if #sections > 0 then
						if #sections == 2 then
							return "󰼏  ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂                              "
								.. table.concat(sections, ".")
								.. ". "
						end
						if #sections == 3 then
							return "󰼐  ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂                                                       "
								.. table.concat(sections, ".")
								.. ". "
						end
						if #sections == 4 then
							return "󰼑  ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂                                                                         "
								.. table.concat(sections, ".")
								.. ". "
						end
						return table.concat(sections, ".") .. ". "
					end
				end,
				-- Turn on / off any sign column related rendering
				sign = false,
				-- Added to the sign column if enabled
				-- The 'level' is used to index into the array using a cycle
				signs = { "", "", " 󱞩", " ", "", "" }, -- 󰻃󰻂󰑊󰨑
				-- Width of the heading background:
				--  block: width of the heading text
				--  full: full width of the window
				-- width = { "block", "full", "block" },
				width = { "full" },
				-- left_margin = { 30, 0, 0, 0 },
				-- left_pad = { 3, 80, 3, 0 },
				-- right_pad = { 3, 2, 10, 1 },
				-- min_width = { 70, 100, 50, 5 },
				left_margin = { 30, 0, 0, 0, 0 },
				left_pad = { 3, 101, 0, 0 },
				right_pad = { 3, 2, 0, 0, 0 },
				min_width = { 70, 140, 100, 100, 100 },
				-- The 'level' is used to index into the array using a clamp
				-- Highlight for the heading icon and extends through the entire line
				backgrounds = {
					"RenderMarkdownH1Bg",
					"RenderMarkdownH2Bg",
					"RenderMarkdownH3Bg",
					"RenderMarkdownH4Bg",
					"RenderMarkdownH5Bg",
					"RenderMarkdownH6Bg",
				},
				-- The 'level' is used to index into the array using a clamp
				-- Highlight for the heading and sign icons
				foregrounds = {
					"RenderMarkdownH1",
					"RenderMarkdownH2",
					"RenderMarkdownH3",
					"RenderMarkdownH4",
					"RenderMarkdownH5",
					"RenderMarkdownH6",
				},
				-- Define custom heading patterns which allow you to override various properties based on
				-- the contents of a heading.
				-- The key is for healthcheck and to allow users to change its values, value type below.
				-- | pattern    | matched against the heading text @see :h lua-pattern |
				-- | icon       | optional override for the icon                       |
				-- | background | optional override for the background                 |
				-- | foreground | optional override for the foreground                 |
				custom = {},
			},
			code = {
				-- Turn on / off code block & inline code rendering
				enabled = true,
				-- Turn on / off any sign column related rendering
				sign = false,
				-- Determines how code blocks & inline code are rendered:
				--  none: disables all rendering
				--  normal: adds highlight group to code blocks & inline code, adds padding to code blocks
				--  language: adds language icon to sign column if enabled and icon + name above code blocks
				--  full: normal + language
				style = "full",
				-- Whether to include the language name next to the icon
				language_name = true,
				-- Determines where language icon is rendered:
				--  right: Right side of code block
				--  left: Left side of code block
				position = "right",
				-- An array of language names for which background highlighting will be disabled
				-- Likely because that language has background highlights itself
				disable_background = {}, -- "diff"
				-- Amount of padding to add to the left of code blocks
				left_pad = 2,
				-- Amount of padding to add to the right of code blocks when width is 'block'
				right_pad = 5,
				left_margin = 0,
				min_width = 100,
				-- Width of the code block background:
				--  block: width of the code block
				--  full: full width of the window
				width = "block",
				-- Determins how the top / bottom of code block are rendered:
				--  thick: use the same highlight as the code body
				--  thin: when lines are empty overlay the above & below icons
				border = "thick",
				-- Used above code blocks for thin border
				above = "▄",
				-- Used below code blocks for thin border
				below = "▀",
				-- Highlight for code blocks
				highlight = "RenderMarkdownCode",
				-- Highlight for inline code
				highlight_inline = "RenderMarkdownCodeInline",
				inline_pad = 1,
			},
			dash = {
				-- Turn on / off thematic break rendering
				enabled = true,
				-- Replaces '---'|'***'|'___'|'* * *' of 'thematic_break'
				-- The icon gets repeated across the window's width
				icon = "",
				-- Width of the generated line:
				--  <integer>: a hard coded width value
				--  full: full width of the window
				width = "full",
				-- Highlight for the whole line generated from the icon
				highlight = "RenderMarkdownDash",
			},
			bullet = {
				-- Turn on / off list bullet rendering
				enabled = true,
				-- Replaces '-'|'+'|'*' of 'list_item'
				-- How deeply nested the list is determines the 'level'
				-- The 'level' is used to index into the array using a cycle
				-- If the item is a 'checkbox' a conceal is used to hide the bullet instead
				--  󰓛 󰨔 󰄱    
				-- icons = { '●', '○', '◆', '◇', '▪', '•', '-', '▫' },
				icons = { "●", "○", "◆", "◇", "▪", "-" },
				-- ordered_icons = {{'1', '2', '3', '4'}, {'a', 'b', 'c'},},
				-- Padding to add to the right of bullet point
				right_pad = 0,
				-- Highlight for the bullet icon
				highlight = "RenderMarkdownBullet",
			},
			-- Checkboxes are a special instance of a 'list_item' that start with a 'shortcut_link'
			-- There are two special states for unchecked & checked defined in the markdown grammar
			checkbox = {
				-- Turn on / off checkbox state rendering
				enabled = true,
				right_pad = 1, -- 체크박스 오른쪽에 추가할 여백
				unchecked = {
					-- Replaces '[ ]' of 'task_list_marker_unchecked'
					icon = "󰄱 ", --  ,󰄱
					-- Highlight for the unchecked icon
					highlight = "RenderMarkdownUnchecked",
					-- Highlight for item associated with checked checkbox.
					scope_highlight = nil,
				},
				checked = {
					-- Replaces '[x]' of 'task_list_marker_checked'
					icon = "󰱒 ", -- '󰡖',  󰗠󰗡󰬧   󰣪 󱌸 󰵿  󰈸
					-- Highligh for the checked icon
					highlight = "RenderMarkdownChecked",
					-- Highlight for item associated with checked checkbox.
					scope_highlight = nil,
				},
				-- Define custom checkbox states, more involved as they are not part of the markdown grammar
				-- As a result this requires neovim >= 0.10.0 since it relies on 'inline' extmarks
				-- Can specify as many additional states as you like following the 'todo' pattern below
				--   The key in this case 'todo' is for healthcheck and to allow users to change its values
				--   'raw': Matched against the raw text of a 'shortcut_link'
				--   'rendered': Replaces the 'raw' value when rendering
				--   'highlight': Highlight for the 'rendered' icon
				custom = {
					todo = {
						raw = "[-]",
						rendered = " 󰥔 TODO ",
						highlight = "RenderMarkdownMySimpleTodo",
						scope_highlight = nil,
					},
					done = { raw = "[x]", rendered = " 󰗠 DONE ", highlight = "RenderMarkdownMySimpleDone" },
					cancel = { raw = "[c]", rendered = " 󰜺 cancel ", highlight = "RenderMarkdownMySimpleCancel" },
					-- log = { raw = "[lg]", rendered = "작성:", highlight = "RenderMarkdownMyLog" },
					result = { raw = "[>]", rendered = "   So 󰜴 ", highlight = "RenderMarkdownResult" },
				},
			},
			quote = {
				-- Turn on / off block quote & callout rendering
				enabled = true,
				-- Replaces '>' of 'block_quote'
				-- icon = '▋▍▏',
				-- icon = '󰍬',
				-- icon = "▐",
				icon = "░",
				repeat_linebreak = false,
				-- Highlight for the quote icon
				highlight = "RenderMarkdownQuote",
			},
			pipe_table = {
				-- Turn on / off pipe table rendering
				enabled = true,
				-- Determines how the table as a whole is rendered:
				--  none: disables all rendering
				--  normal: applies the 'cell' style rendering to each row of the table
				--  full: normal + a top & bottom line that fill out the table when lengths match
				style = "full",
				-- Determines how individual cells of a table are rendered:
				--  overlay: writes completely over the table, removing conceal behavior and highlights
				--  raw: replaces only the '|' characters in each row, leaving the cells unmodified
				--  padded: raw + cells are padded with inline extmarks to make up for any concealed text
				cell = "padded",
				-- Gets placed in delimiter row for each column, position is based on alignmnet
				alignment_indicator = "━",
    -- Characters used to replace table border
    -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal
    -- stylua: ignore
        border = {
          '┌', '┬', '┐',
          '├', '┼', '┤',
          '└', '┴', '┘',
          '│', '─',
        },
				-- Highlight for table heading, delimiter, and the line above
				head = "RenderMarkdownTableHead",
				-- Highlight for everything else, main table rows and the line below
				row = "RenderMarkdownTableRow",
				-- Highlight for inline padding used to add back concealed space
				filler = "RenderMarkdownTableFill",
			},
			-- Callouts are a special instance of a 'block_quote' that start with a 'shortcut_link'
			-- Can specify as many additional values as you like following the pattern from any below, such as 'note'
			--   The key in this case 'note' is for healthcheck and to allow users to change its values
			-- | raw        | matched against the raw text of a 'shortcut_link', case insensitive |
			-- | rendered   | replaces the 'raw' value when rendering                             |
			-- | highlight  | highlight for the 'rendered' text and quote markers                 |
			-- | quote_icon | optional override for quote.icon value for individual callout       |
			--  󰓛 󰄱    
			--      󱓻강 sdf   sfd  󱓼  󰨔 󰴩     
			callout = {
				note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "Re,derMarkdownInfo" },
				tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
				important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
				warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
				caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
				-- Obsidian: https://help.a.md/Editing+and+formatting/Callouts
				abstract = { raw = "[!ABSTRACT]", rendered = "󰨸 Abstract", highlight = "RenderMarkdownInfo" },
				success = { raw = "[!SUCCESS]", rendered = "󰄬 Success", highlight = "RenderMarkdownSuccess" },
				question = { raw = "[!QUESTION]", rendered = "󰘥 Question", highlight = "RenderMarkdownWarn" },
				failure = { raw = "[!FAILURE]", rendered = "󰅖 Failure", highlight = "RenderMarkdownError" },
				danger = { raw = "[!DANGER]", rendered = "󱐌 Danger", highlight = "RenderMarkdownError" },
				bug = { raw = "[!BUG]", rendered = "󰨰 Bug", highlight = "RenderMarkdownError" },
				example = { raw = "[!EXAMPLE]", rendered = "󰉹 Example", highlight = "RenderMarkdownHint" },
				quote = { raw = "[!QUOTE]", rendered = "󱆨 Quote", highlight = "RenderMarkdownQuote" },
				error = { raw = "[!ERROR]", rendered = " Error", highlight = "RenderMarkdownRed" },
				-- My own
				test = { raw = "[!ts]", rendered = "󰨸 TEST ", highlight = "RenderMarkdownMyTest" },
				todo = { raw = "[!td]", rendered = "󰗕 TODO ", highlight = "RenderMarkdownMyTodo" },
				todofin = { raw = "[!dt]", rendered = "󰈼 fin ", highlight = "RenderMarkdownMyTodoFin" },
				my_question = { raw = "[!qt]", rendered = "󰴩.", highlight = "RenderMarkdownMyQuestion" },
				reference = { raw = "[!rf]", rendered = "󰉢 REFERENCE ", highlight = "RenderMarkdownMyReference" },
				log = { raw = "[!lg]", rendered = "󰨸 Log ", highlight = "RenderMarkdownMyTest" },
				concept = { raw = "[!cn]", rendered = "󰃁 개념정리 ", highlight = "RenderMarkdownBlue" },

				my_red = { raw = "[!re]", rendered = "", highlight = "RenderMarkdownRed" },
				my_blue = { raw = "[!bl]", rendered = "", highlight = "RenderMarkdownBlue" },
				my_green = { raw = "[!gr]", rendered = "", highlight = "RenderMarkdownGreen" },
				my_yellow = { raw = "[!ye]", rendered = "", highlight = "RenderMarkdownYellow" },
			},
			link = {
				-- Turn on / off inline link icon rendering
				enabled = true,
				-- Inlined with 'image' elements.
				image = "󰥶 ",
				-- Inlined with 'email_autolink' elements.
				email = "󰀓 ",
				-- Fallback icon for 'inline_link' and 'uri_autolink' elements.
				hyperlink = "󰌹 ", -- 
				-- Applies to the inlined icon
				highlight = "RenderMarkdownDocLink",
				wiki = {
					icon = "󱗖 ",
					body = function()
						return nil
					end,
					highlight = "RenderMarkdownYoutubeLink",
				},
				-- Define custom destination patterns so icons can quickly inform you of what a link
				-- contains. Applies to 'inline_link', 'uri_autolink', and wikilink nodes. When multiple
				-- patterns match a link the one with the longer pattern is used.
				custom = {
					file = { pattern = "^file:", icon = " ", highlight = "RenderMarkdownFileLink" },
					youtube = { pattern = "youtube%.com", icon = " ", highlight = "RenderMarkdownYoutubeLink" },
					web = { pattern = "^http", icon = "󰖟 ", highlight = "RenderMarkdownWebLink" },
					diary = { pattern = "^%d%d%d%d%-%d%d%-%d%d", icon = " ", highlight = "RenderMarkdownDiaryLink" },
					discord = { pattern = "discord%.com", icon = "󰙯 " },
					github = { pattern = "github%.com", icon = "󰊤 " },
					gitlab = { pattern = "gitlab%.com", icon = "󰮠 " },
					google = { pattern = "google%.com", icon = "󰊭 " },
					neovim = { pattern = "neovim%.io", icon = " " },
					reddit = { pattern = "reddit%.com", icon = "󰑍 " },
					stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 " },
					wikipedia = { pattern = "wikipedia%.org", icon = "󰖬 " },
					-- TODO:
					-- today = { pattern = '^2024%-09%-12', icon = ' ', highlight = 'RenderMarkdownDiaryLink' }, -- today = os.date("%Y-%m-%d") 해서 사용하고싶은데 이게 안되네
				},
			},
			sign = {
				-- Turn on / off sign rendering
				enabled = true,
				-- Applies to background of sign text
				highlight = "RenderMarkdownSign",
			},
			-- Window options to use that change between rendered and raw view
			win_options = {
				-- See :h 'conceallevel'
				conceallevel = {
					-- Used when not being rendered, get user setting
					default = vim.api.nvim_get_option_value("conceallevel", {}),
					-- Used when being rendered, concealed text is completely hidden
					rendered = 3,
				},
				-- See :h 'concealcursor'
				concealcursor = {
					-- Used when not being rendered, get user setting
					default = vim.api.nvim_get_option_value("concealcursor", {}),
					-- Used when being rendered, disable concealing text in all modes
					rendered = "",
				},
				-- showbreak = { default = vim.api.nvim_get_option_value('showbreak', {}), rendered = '  ' },
				showbreak = { default = vim.api.nvim_get_option_value("showbreak", {}), rendered = "" },
				-- breakindent = { default = vim.api.nvim_get_option_value("breakindent", {}), rendered = true },
				breakindent = { default = vim.api.nvim_get_option_value("breakindent", {}), rendered = false },
				breakindentopt = { default = vim.api.nvim_get_option_value("breakindentopt", {}), rendered = "" },
			},
			-- More granular configuration mechanism, allows different aspects of buffers
			-- to have their own behavior. Values default to the top level configuration
			-- if no override is provided. Supports the following fields:
			--   enabled, max_file_size, debounce, render_modes, anti_conceal, heading, code,
			--   dash, bullet, checkbox, quote, pipe_table, callout, link, sign, win_options
			overrides = {
				-- Overrides for different buftypes, see :h 'buftype'
				buftype = {
					-- 요놈은 hover document에 적용된다.
					nofile = {
						-- enabled = false,
						code = {
							style = "full",
							position = "right",
							language_name = true,
							language_pad = 0,
							left_pad = 0,
							-- Amount of padding to add to the right of code blocks when width is 'block'
							right_pad = 0,
							left_margin = 0,
							min_width = 100,
							width = "full",
							border = "thick",
							highlight = "RenderMarkdownCodeNofile",
						},
					},
				},
				filetype = {
					Avante = {
						heading = {
							width = { "full", "full", "full" },
							left_margin = { 0, 0, 0, 0 },
							left_pad = { 0, 0, 0, 0 },
							right_pad = { 0, 0, 0, 0 },
							min_width = { 0, 0, 0, 0 },
						},
						sign = { enabled = false },
						code = {
							style = "full",
							position = "right",
							language_name = true,
							language_pad = 0,
							left_pad = 2,
							-- Amount of padding to add to the right of code blocks when width is 'block'
							right_pad = 0,
							left_margin = 0,
							-- min_width = 100,
							width = "full",
							border = "thick",
							highlight = "RenderMarkdownCodeAvante",
						},
						quote = {
							repeat_linebreak = true,
						},
						indent = { enabled = false },
					},
					AvanteInput = {
						heading = {
							width = { "full", "full", "full" },
							left_margin = { 0, 0, 0, 0 },
							left_pad = { 0, 0, 0, 0 },
							right_pad = { 0, 0, 0, 0 },
							min_width = { 0, 0, 0, 0 },
						},
						sign = { enabled = false },
						code = {
							style = "normal",
							position = "left",
							language_name = false,
							language_pad = 0,
							left_pad = 2,
							-- Amount of padding to add to the right of code blocks when width is 'block'
							right_pad = 0,
							left_margin = 0,
							min_width = 100,
							width = "full",
							border = "thin",
							highlight = "RenderMarkdownCodeAvante",
						},
						quote = {
							repeat_linebreak = true,
						},
						indent = { enabled = false },
					},
					["copilot-chat"] = {
						heading = {
							width = { "full", "full", "full" },
							left_margin = { 0, 0, 0, 0 },
							left_pad = { 0, 0, 0, 0 },
							right_pad = { 0, 0, 0, 0 },
							min_width = { 0, 0, 0, 0 },
						},
						indent = { enabled = false },
					},
				},
				-- https://github.com/MeanderingProgrammer/render-markdown.nvim/discussions/285
				-- https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/873bdee
				-- floating window에서의 기능 여부
				-- buflisted = { [false] = { enabled = false } },
			},
			-- Mapping from treesitter language to user defined handlers
			-- See 'Custom Handlers' document for more info
			custom_handlers = {},
		},
	},

	-- 딱히 필요한 일이 많지 않더라?
	-- {
	-- 	"iamcco/markdown-preview.nvim",
	-- 	ft = "markdown",
	-- 	lazy = true,
	-- 	build = "cd app && npm install && git reset --hard",
	-- },

	{
		"greyhairchooselife/markdowny.nvim",
		event = "BufEnter *.md",
		-- BUG:: 왜 안돼??? 플러그인도 수정해서 파일 타입 추가해줬는데...
		ft = { "copilot-chat", "AvanteInput" },
	},
	{
		"vhyrro/luarocks.nvim",
		priority = 1001, -- this plugin needs to run before anything else
		opts = {
			rocks = { "magick" },
		},
	},
	{
		"3rd/image.nvim",
		dependencies = { "luarocks.nvim" },
		lazy = false,
		cond = function()
			-- SSH 연결 여부 확인
			local is_ssh = os.getenv("SSH_CLIENT") ~= nil
				or os.getenv("SSH_TTY") ~= nil
				or os.getenv("SSH_CONNECTION") ~= nil

			return not is_ssh -- SSH가 아닐 때만 플러그인 로드
		end,
		opts = {
			-- backend = "kitty", -- kitty 터미널로 실행하면 매우 잘 된다. 크기 변경 등 더 매끄럽다.
			backend = "ueberzug",
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
				},
				neorg = {
					enabled = false,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "norg" },
				},
			},
			max_width = nil,
			max_height = nil,
			max_width_window_percentage = nil,
			max_height_window_percentage = 80,
			window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
			editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
			tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
			hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- render image files as images when opened
			scale_factor = 1.0,
		},
	},

	{
		"backdround/global-note.nvim",
		cmd = { "GlobalNote", "LocalNote" },
		opts = {},
		config = function()
			require("global-note").setup({
				filename = "global-note.md",
				directory = "~/Documents/global-note/",
				title = "     Global     ",
				command_name = "GlobalNote",

				-- A nvim_open_win config to show float window.
				-- table or fun(): table
				window_config = function()
					local window_height = vim.api.nvim_list_uis()[1].height
					local window_width = vim.api.nvim_list_uis()[1].width
					return {
						relative = "editor",
						-- border = require("utils").borders.full,
						border = "rounded",
						-- Can be one of the pre-defined styles: `"double"`, `"none"`, `"rounded"`, `"shadow"`, `"single"` or `"solid"`.
						-- style = "minimal",
						title_pos = "center",
						width = math.floor(0.7 * window_width),
						height = math.floor(0.85 * window_height),
						row = math.floor(0.05 * window_height),
						col = math.floor(0.15 * window_width),
					}
				end,

				-- It's called after the window creation.
				-- fun(buffer_id: number, window_id: number)
				post_open = function(_, _)
					-- 윈도우 옵션 설정
					-- vim.wo.winhl =
					-- 	"Normal:NoteBackground,FloatBorder:NoteBorder,FloatTitle:NoteTitle,EndOfBuffer:NoteEOB,FoldColumn:NoteFoldColumn"

					-- vim.wo.number = false
					-- vim.wo.foldcolumn = "2"
					-- vim.wo.relativenumber = false
					-- vim.wo.cursorline = false
					-- vim.wo.signcolumn = "no"

					-- 버퍼 옵션 설정
					vim.bo.filetype = "markdown"
				end,

				additional_presets = {
					-- projects = {
					-- 	filename = "projects-to-do.md",
					-- 	title = "List of projects",
					-- 	command_name = "ProjectsNote",
					-- 	-- All not specified options are used from the root.
					-- },
					project_local = {
						command_name = "LocalNote",
						title = "     Local     ",
						filename = function()
							local project_name = require("utils").get_project_name_by_git({ print_errors = false })
								or require("utils").get_project_name_by_cwd()
							return project_name .. ".md"
						end,

						post_open = function(_, _)
							vim.wo.winhl =
								"Normal:NoteBackground,FloatBorder:LocalNoteBorder,FloatTitle:LocalNoteTitle,EndOfBuffer:NoteEOB,FoldColumn:NoteFoldColumn"
							vim.wo.number = false
							vim.wo.foldcolumn = "2"
							vim.wo.relativenumber = false
							vim.wo.cursorline = false
							vim.wo.signcolumn = "no"
						end,
					},
				},
			})
		end,
	},
}
