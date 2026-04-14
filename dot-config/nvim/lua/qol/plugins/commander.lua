return {
    "greyhairchooselife/commander.nvim",
    -- dir = "/home/sy/commander.nvim",
    keys = {
        {
            ",.c",
            function() require("commander").show({}) end,
            desc = "commander showing",
            mode = { "n", "v", "x", "c" },
        },
    },
    opts = {
        components = { "DESC", "KEYS", "CMD", "CAT" },
        sort_by = { "DESC", "KEYS", "CMD", "CAT" },
        separator = "  ",
        auto_replace_desc_with_cmd = true,
        prompt_title = "Commander",
        source_file = os.getenv("HOME") .. "/dotfiles/dot-config/nvim/lua/qol/modules/commands_source.yaml",
        integration = {
            snacks = { enable = true },
            lazy = { enable = false, set_plugin_name_as_cat = false },
        },
    },
}
