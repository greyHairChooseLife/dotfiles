return {
    "ravitemer/mcphub.nvim",
    event = "VeryLazy",
    enabled = false,
    build = "npm install -g mcp-hub@latest",
    config = function() require("mcphub").setup() end,
}
