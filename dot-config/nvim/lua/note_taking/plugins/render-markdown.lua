return {
    "MeanderingProgrammer/render-markdown.nvim",
    -- lazy = false,
    -- commit = "5cec1bb5fb11079a88fd5b3abd9c94867aec5945",
    -- event = "BufEnter *.md",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
    ft = { "markdown", "vimwiki", "gitcommit", "codecompanion" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        -- Whether Markdown should be rendered by default or not
        enabled = true,
        -- Filetypes this plugin will run on
        file_types = {
            "markdown",
            "vimwiki",
            "gitcommit",
            "codecompanion",
        },
        -- Takes buffer as input, if it returns true this plugin will not attach to the buffer
        ignore = function() return false end,
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
        render_modes = { "n", "v", "V", "c", "i" },
        nested = false,
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
            enabled = true,
            render_modes = { "n", "v", "V", "c" },
            -- Executable used to convert latex formula to rendered unicode
            converter = { "utftex", "latex2text" },
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
                        return " ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂                              "
                            .. table.concat(sections, ".")
                            .. ". "
                    end
                    if #sections == 3 then
                        return " ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂                                                       "
                            .. table.concat(sections, ".")
                            .. ". "
                    end
                    if #sections == 4 then
                        return " ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂                                                                         "
                            .. table.concat(sections, ".")
                            .. ". "
                    end
                    if #sections == 5 then return " ▁▁▁▁ " end
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
            custom = {
                TODO = {
                    pattern = "TODO",
                    background = "RenderMarkdownMyTodoHeader",
                },
                -- 다 했으면 그런 헤더는 사라져야지?
                -- TODOfin = {
                --   pattern = "TODO:fin",
                --   background = "RenderMarkdownMyTodoFinHeader",
                -- },
                REFERENCE = {
                    pattern = "REFERENCE",
                    background = "RenderMarkdownMyReferenceHeader",
                },
            },
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
            language_pad = 1,
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
            language_border = "█",
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
            -- Replaces '---'|'***'|'___'|'* * *' of 'thematic_break'    〰️ ▔
            -- The icon gets repeated across the window's width
            icon = "",
            -- icon = "",
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
            -- scope_highlight = { "RenderMarkdownBulletItem", "Normal", "Normal", "Normal", "Normal", "Normal" },
            -- scope_priority = 5,
        },
        -- Checkboxes are a special instance of a 'list_item' that start with a 'shortcut_link'
        -- There are two special states for unchecked & checked defined in the markdown grammar
        checkbox = {
            -- Turn on / off checkbox state rendering
            enabled = true,
            left_pad = 0,
            right_pad = 1, -- 체크박스 오른쪽에 추가할 여백
            unchecked = {
                -- Replaces '[ ]' of 'task_list_marker_unchecked'
                icon = "󰄱", --  ,󰄱
                -- Highlight for the unchecked icon
                highlight = "RenderMarkdownUnchecked",
                -- Highlight for item associated with checked checkbox.
                scope_highlight = "RenderMarkdownUncheckedScope",
            },
            checked = {
                -- Replaces '[x]' of 'task_list_marker_checked'
                icon = "󰱒", -- '󰡖',  󰗠󰗡󰬧   󰣪 󱌸 󰵿  󰈸
                -- Highligh for the checked icon
                highlight = "RenderMarkdownChecked",
                -- Highlight for item associated with checked checkbox.
                scope_highlight = "RenderMarkdownCheckedScope",
            },
            -- Define custom checkbox states, more involved as they are not part of the markdown grammar
            -- As a result this requires neovim >= 0.10.0 since it relies on 'inline' extmarks
            -- Can specify as many additional states as you like following the 'todo' pattern below
            --   The key in this case 'todo' is for healthcheck and to allow users to change its values
            --   'raw': Matched against the raw text of a 'shortcut_link'
            --   'rendered': Replaces the 'raw' value when rendering
            --   'highlight': Highlight for the 'rendered' icon
            -- NOTE:: 우측에 공백이 하나 있어야만 렌더링이 된다.
            -- NOTE:: 좌측에 '-' 기호가 있어야만 렌더 링된다.
            custom = {
                todo = {
                    raw = "[-]",
                    rendered = " 󰥔 TODO ",
                    highlight = "RenderMarkdownMySimpleTodo",
                    scope_highlight = nil,
                },
                done = { raw = "[x]", rendered = " 󰗠 DONE ", highlight = "RenderMarkdownMySimpleDone" },
                cancel = { raw = "[cc]", rendered = " 󰜺 cancel ", highlight = "RenderMarkdownMySimpleCancel" },
                checkbox_cancel = {
                    raw = "[c]",
                    rendered = "",
                    highlight = "RenderMarkdownCancel",
                    scope_highlight = "RenderMarkdownCancelScope",
                },
                -- log = { raw = "[lg]", rendered = "작성:", highlight = "RenderMarkdownMyLog" },
                result = { raw = "[>]", rendered = " 󰜴 ", highlight = "RenderMarkdownResult" },
            },
        },
        html = {
            enabled = true,
            render_modes = false,
            comment = {
                -- Turn on / off HTML comment concealing.
                conceal = true,
                -- Optional text to inline before the concealed comment.
                text = nil,
                -- Highlight for the inlined text.
                highlight = "RenderMarkdownHtmlComment",
            },
            tag = {
                url = { icon = "󰖟 ", highlight = "RenderMarkdownWebLink" },
                buf = { icon = " ", highlight = "RenderMarkdownHtmlBUF" },
                file = { icon = " ", highlight = "RenderMarkdownFileLink" },
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
        callout = {
            -- Callouts are a special instance of a 'block_quote' that start with a 'shortcut_link'
            -- Can specify as many additional values as you like following the pattern from any below, such as 'note'
            --   The key in this case 'note' is for healthcheck and to allow users to change its values
            -- | raw        | matched against the raw text of a 'shortcut_link', case insensitive |
            -- | rendered   | replaces the 'raw' value when rendering                             |
            -- | highlight  | highlight for the 'rendered' text and quote markers                 |
            -- | quote_icon | optional override for quote.icon value for individual callout       |
            --  󰓛 󰄱        󱓻강 sdf   sfd  󱓼  󰨔 󰴩     
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
            note = { raw = "[!NOTE]", rendered = "󰌶 Note", highlight = "RenderMarkdownMyNote", category = "github" },
            -- My own
            test = { raw = "[!ts]", rendered = "󰨸 TEST ", highlight = "RenderMarkdownMyTest" },
            todo = { raw = "[!td]", rendered = " 󰥔 TODO ", highlight = "RenderMarkdownMySimpleTodo" },
            tododone = { raw = "[!tdd]", rendered = " 󰗠 DONE ", highlight = "RenderMarkdownMySimpleDone" },
            todocancel = { raw = "[!tdc]", rendered = " 󰜺 CANCEl ", highlight = "RenderMarkdownMySimpleCancel" },
            my_question = { raw = "[!qt]", rendered = "󰴩.", highlight = "RenderMarkdownMyQuestion" },
            reference = { raw = "[!rf]", rendered = "󰉢 REFERENCE ", highlight = "RenderMarkdownMyReference" },
            log = { raw = "[!lg]", rendered = "󰨸 Log ", highlight = "RenderMarkdownMyTest" },
            concept = { raw = "[!cn]", rendered = "󰃁 개념정리 ", highlight = "RenderMarkdownBlue" },

            my_red = { raw = "[!re]", rendered = "⚡ ", highlight = "RenderMarkdownRed" }, -- 
            my_blue = { raw = "[!bl]", rendered = "⚡ ", highlight = "RenderMarkdownBlue" },
            my_green = { raw = "[!gr]", rendered = "⚡ ", highlight = "RenderMarkdownGreen" },
            my_yellow = { raw = "[!ye]", rendered = "⚡ ", highlight = "RenderMarkdownYellow" },
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
                body = function() return nil end,
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
                -- google = { pattern = "google%.com", icon = "󰊭 " },
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
        document = {
            enabled = false,
            -- 숨기기 기능
            conceal = {
                char_patterns = { ":%S-:%s" },
                line_patterns = {
                    "^%-%-%-\n.-\n%-%-%-\n", -- 시작 부분 메타데이터
                    "\n%-%-%-\n.-\n%-%-%-\n", -- 중간 부분 메타데이터
                },
            },
        },
        win_options = {
            -- Window options to use that change between rendered and raw view
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
                rendered = "n",
            },
            -- showbreak = { default = vim.api.nvim_get_option_value('showbreak', {}), rendered = '  ' },
            showbreak = { default = vim.api.nvim_get_option_value("showbreak", {}), rendered = "" },
            -- breakindent = { default = vim.api.nvim_get_option_value("breakindent", {}), rendered = true },
            breakindent = { default = vim.api.nvim_get_option_value("breakindent", {}), rendered = false },
            breakindentopt = { default = vim.api.nvim_get_option_value("breakindentopt", {}), rendered = "" },
        },
        overrides = {
            -- More granular configuration mechanism, allows different aspects of buffers
            -- to have their own behavior. Values default to the top level configuration
            -- if no override is provided. Supports the following fields:
            --   enabled, max_file_size, debounce, render_modes, anti_conceal, heading, code,
            --   dash, bullet, checkbox, quote, pipe_table, callout, link, sign, win_options
            buftype = {
                -- Overrides for different buftypes, see :h 'buftype'
                nofile = {
                    -- 요놈은 hover document에 적용된다.
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
                codecompanion = {
                    heading = {
                        width = { "full", "full", "full" },
                        left_margin = { 0, 0, 0, 0 },
                        left_pad = { 0, 0, 0, 0 },
                        right_pad = { 0, 0, 0, 0 },
                        min_width = { 0, 0, 0, 0 },
                        border = { false, false, true },
                        border_virtual = false,
                        border_prefix = false,
                        above = "", -- ▂
                        -- Used below heading for border
                        below = " ", -- ▔▀
                        backgrounds = {
                            "CodeCompanionH1Bg",
                            "CodeCompanionH2Bg",
                            "CodeCompanionH3Bg",
                            "CodeCompanionH4Bg",
                            "CodeCompanionH5Bg",
                            "CodeCompanionH6Bg",
                        },

                        icons = function(ctx)
                            local sections = ctx.sections
                            table.remove(sections, 1)
                            if #sections > 0 then
                                -- if #sections == 1 then
                                -- 	return "󰯆 󰯆 󰯆  DO NOT use this header. (msg under this wouldn't send to LLM.) 󰯆 󰯆 󰯆                             "
                                -- end
                                if #sections == 1 then return " ▂▂▂▂   " end
                                if #sections == 2 then return "   ▂▂▂▂▂▂   " end
                                if #sections == 3 then return "     ▂▂▂▂▂▂   " end
                                if #sections == 4 then return "       ▂▂▂▂▂▂   " end
                                return table.concat(sections, ".")
                            end
                        end,
                        custom = {
                            Me = {
                                pattern = " 󰟷",
                                icon = "", -- Example icon
                                background = "CodeCompanionMeHeader",
                                -- foreground = "RenderMarkdownH1",
                            },
                            Copilot = {
                                pattern = "󱞩  ",
                                icon = "", -- Example icon
                                background = "CodeCompanionCopilotHeader",
                            },
                        },
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
                        highlight = "RenderMarkdownCodeCodeCompanion",
                        highlight_border = "RenderMarkdownCodeCodeCompanion",
                    },
                    quote = {
                        repeat_linebreak = true,
                    },
                    indent = { enabled = false },
                },
            },
            -- https://github.com/MeanderingProgrammer/render-markdown.nvim/discussions/285
            -- https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/873bdee
            -- floating window에서의 기능 여부
            -- buflisted = { [false] = { enabled = vim.bo.filetype == "codecompanion" and false or true } },
        },
        custom_handlers = {
            -- Mapping from treesitter language to user defined handlers
            -- See 'Custom Handlers' document for more info
        },
    },
}
