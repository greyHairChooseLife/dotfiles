return {
    "olimorris/codecompanion.nvim",
    event = "VeryLazy",
    -- commit = "a869f19", -- util function lost
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        -- "j-hui/fidget.nvim",
        {
            "echasnovski/mini.diff",
            config = function()
                local diff = require("mini.diff")
                diff.setup({
                    -- Disable column style
                    view = { style = "number" },
                    -- Disabled by default
                    source = diff.gen_source.none(),
                    -- Disable all default mappings
                    mappings = {
                        apply = "",
                        reset = "",
                        textobject = "",
                        goto_first = "",
                        goto_prev = "",
                        goto_next = "",
                        goto_last = "",
                    },
                })
            end,
        },
        {
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            enabled = false,
            opts = {
                filetypes = {
                    codecompanion = {
                        prompt_for_file_name = false,
                        template = "[Image]($FILE_PATH)",
                        use_absolute_path = true,
                    },
                },
            },
        },
        -- EXTENSIONS
        "ravitemer/codecompanion-history.nvim",
        -- "ravitemer/mcphub.nvim",
    },
    init = function()
        vim.cmd([[cab ccc CodeCompanionCmd]])
        vim.cmd([[cab cc CodeCompanion]]) -- inline
        vim.cmd([[cab cca CodeCompanionActions]])
    end,
    config = function()
        require("codecompanion").setup({
            display = {
                chat = {
                    intro_message = "",
                    show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
                    separator = "=", -- The separator between the different messages in the chat buffer
                    show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
                    show_settings = false, -- Show LLM settings at the top of the chat buffer?
                    show_token_count = false, -- Show the token count for each response?
                    start_in_insert_mode = false, -- Open the chat buffer in insert mode?
                    show_context = true, -- Show context (from slash commands and variables) in the chat buffer?
                    fold_context = false, -- Fold context in the chat buffer?
                    fold_reasoning = true, -- Fold the reasoning content from the LLM in the chat buffer?
                    show_tools_processing = true, -- Show the loading message when tools are being executed?

                    icons = {
                        -- pinned_buffer = " ",
                        -- watched_buffer = "󰴅 ",
                        buffer_pin = " ",
                        buffer_watch = "󰴅 ", -- 󰂥
                        --chat_context = " ",
                        chat_fold = " ",
                        tool_success = " ",
                        tool_failure = " ",
                    },
                    window = {
                        height = 0.8,
                        width = math.max(math.min(math.floor(0.45 * vim.o.columns), 135), 100), -- 최대 135, 최소 100
                        opts = {
                            signcolumn = "yes:1",
                        },
                    },
                },
                action_palette = {
                    width = 95,
                    height = 10,
                    prompt = "Prompt ", -- Prompt used for interactive LLM calls
                    provider = "snacks", -- default|telescope|mini_pick
                    opts = {
                        show_default_actions = false, -- Show the default actions in the action palette?
                        show_default_prompt_library = false, -- Show the default prompt library in the action palette?
                    },
                },
                diff = {
                    enabled = true,
                    close_chat_at = 1,
                    provider = "mini_diff", -- codecompanion의 내장 diff를 제공한다는데 시도해보자. 2025-08-31, 6bc36af feat(diff): native inline diff and super diff
                    opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
                },
            },
            adapters = {
                http = {
                    opts = {
                        show_defaults = false,
                        show_model_choices = true,
                    },
                    copilot = function()
                        return require("codecompanion.adapters").extend("copilot", {
                            -- github copilot premium request calculation
                            -- https://docs.github.com/en/copilot/about-github-copilot/github-copilot-features#user-content-fnref-2
                            schema = {
                                model = {
                                    default = "grok-code-fast-1",
                                    -- default = "gpt-4.1",
                                    -- default = "claude-sonnet-4",
                                    -- default = "claude-3.7-sonnet",
                                    -- default = "claude-3.7-sonnet-thought",
                                },
                            },
                        })
                    end,
                    anthropic = function() return require("codecompanion.adapters").extend("anthropic", {}) end,
                },
            },
            strategies = {
                chat = {
                    roles = {
                        ---The header name for the LLM's messages
                        ---@type string|fun(adapter: CodeCompanion.Adapter): string
                        llm = function(adapter) return " 󱞩   _" .. adapter.formatted_name end,

                        ---The header name for your messages
                        ---@type string
                        user = " 󰟷",
                        ---Decorate the user message before it's sent to the LLM
                        prompt_decorator = function(message, adapter, context) return string.format([[<prompt>%s</prompt>]], message) end,
                    },
                    keymaps = {
                        close = { modes = { n = "<C-c>", i = "<C-c>" } },
                        send = { modes = { i = { "<C-s>", "<A-Enter>" } } },
                        stop = { modes = { n = "<Esc><Esc><Esc>" } },
                        pin = { modes = { n = "grp" } },
                        watch = { modes = { n = "grw" } },
                        goto_file_under_cursor = { modes = { n = "gO" } },
                        clear = { modes = { n = "gX" } },
                        previous_header = { modes = { n = "<C-p>" } },
                        next_header = { modes = { n = "<C-n>" } },
                        previous_chat = { modes = { n = "]]" } },
                        next_chat = { modes = { n = "[[" } },
                        system_prompt = { modes = { n = "gts" } }, -- toggle system prompts
                        yolo_mode = { modes = { n = "gta" } }, -- toggle auto tool mode
                        regenerate = { modes = { n = "gR" } },
                        copilot_stats = { modes = { n = "gs" } },
                    },
                    adapter = {
                        name = "copilot",
                        -- model = "gpt-4.1",
                        model = "grok-code-fast-1",
                    },
                    slash_commands = require("AI.codecompanion.slash_commands"),
                    tools = require("AI.codecompanion.tools"),
                    -- variables = {},
                },
                inline = {
                    adapter = {
                        name = "copilot",
                        -- model = "gpt-4.1",
                        model = "grok-code-fast-1",
                    },
                    keymaps = {
                        accept_change = { modes = { n = "ca" } },
                        reject_change = { modes = { n = "cr" } },
                    },
                },
            },
            prompt_library = require("AI.codecompanion.prompt_library"),
            -- opts = { system_prompt = require("AI.codecompanion.system_prompts.v3") }, -- 기본 제공 시스템 프롬프트로 돌아가자. 2025-08-31
            extensions = require("AI.codecompanion.extensions"),
        })

        -- MEMO:: setup custom utils
        require("AI.codecompanion.utils.basic_autocmd_as_callback").setup()
        require("AI.codecompanion.utils.diff_highlights").setup()
        require("AI.codecompanion.utils.extmarks").setup()
        require("AI.codecompanion.utils.save_english_study_records").setup()
        require("AI.codecompanion.utils.save_english_study_notes").setup()
    end,
}
