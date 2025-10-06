return {
    {
        "greyhairchooselife/tts.nvim",
        cmd = { "TTS" },
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- yay -S python-edge-tts
        },
        opts = {
            voice = "en-IE-EmilyNeural",
            speed = 1.2,
        },
    },
    {
        "kyza0d/vocal.nvim",
        -- event = "VeryLazy",
        cmd = { "Vocal" },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("vocal").setup({
                -- API key (string, table with command, or nil to use OPENAI_API_KEY env var)
                api_key = nil,

                -- Directory to save recordings
                recording_dir = os.getenv("HOME") .. "/Music/recordings",

                -- Delete recordings after transcription
                delete_recordings = true,

                -- Keybinding to trigger :Vocal (set to nil to disable)
                -- keymap = ",v",
                keymap = nil,

                -- Local model configuration (set this to use local model instead of API)
                --
                -- local_model = {
                --   model = "base",       -- Model size: tiny, base, small, medium, large
                --   path = "~/whisper",   -- Path to download and store models
                -- },

                -- API configuration (used only when local_model is not set)
                api = {
                    model = "whisper-1",
                    language = nil, -- Auto-detect language
                    response_format = "json",
                    temperature = 0,
                    timeout = 60,
                },
            })
        end,
    },
}
