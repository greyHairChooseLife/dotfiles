return {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- use latest release, remove to use latest commit
    ft = "markdown",
    cmd = "Obsidian",
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
        legacy_commands = false, -- this will be removed in the next major release
        workspaces = {
            {
                name = "dev",
                path = "~/Documents/vaults/dev/3.resource/inbox",
            },
            {
                name = "work",
                path = "~/Documents/vaults/work/",
            },
            {
                name = "personal",
                path = "~/Documents/vaults/personal",
            },
        },
    },
}
