return {
    -- MEMO:: touch default
    ["buffer"] = {
        opts = { provider = "snacks" },
        keymaps = { modes = {
            i = "<C-b>",
            n = { "<C-b>" },
        } },
    },
    ["file"] = { opts = { provider = "snacks" }, keymaps = { modes = {
        i = "<C-f>",
        n = { "<C-f>" },
    } } },
    ["help"] = { opts = { provider = "snacks" } },
    ["symbols"] = { opts = { provider = "snacks" } },

    -- MEMO:: custom
    --
    --
    -- DEPRECATED:: 2025-05-09
    -- ["delete_session"] = require("AI.codecompanion.slash_commands.deprecated.delete_session"),
    -- ["dump_session"] = require("AI.codecompanion.slash_commands.deprecated.dump_session"),
    -- ["restore_session"] = require("AI.codecompanion.slash_commands.deprecated.restore_session"),
    -- ["git_commit"] = require("AI.codecompanion.slash_commands.deprecated.git_commit"),
    -- ["thinking"] = require("AI.codecompanion.slash_commands.deprecated.thinking"),
    -- ["agent_mode"] = require("AI.codecompanion.slash_commands.deprecated.agent_mode"),
    -- ["plan_mode"] = require("AI.codecompanion.slash_commands.deprecated.plan_mode"),
    -- ["bilingual"] = require("AI.codecompanion.slash_commands.deprecated.bilingual"),
    -- ["emoji"] = require("AI.codecompanion.slash_commands.deprecated.emoji"),
    -- ["chinese"] = require("AI.codecompanion.slash_commands.deprecated.chinese"),
    -- ["codeforces_companion"] = require("AI.codecompanion.slash_commands.deprecated.codeforces_companion"),
    -- ["review_merge_request"] = require("AI.codecompanion.slash_commands.deprecated.review_merge_request"),
    -- ["review_git_diffs"] = require("AI.codecompanion.slash_commands.deprecated.review_git_diffs"),
    -- ["graphviz"] = require("AI.codecompanion.slash_commands.deprecated.graphviz"),
    -- ["summarize_text"] = require("AI.codecompanion.slash_commands.deprecated.summarize_text"),
}
