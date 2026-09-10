return {
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
}
