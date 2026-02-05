local on_slash_commands = "AI.codecompanion.prompt_library.on_slash_commands."
local on_keymaps = "AI.codecompanion.prompt_library.on_keymaps."
local on_palette = "AI.codecompanion.prompt_library.on_palette."

return {
    -- off action palette & slash_command only
    -- ["os1"] = require(on_slash_commands .. "get_full_git_status_reference"),
    -- ["os2"] = require(on_slash_commands .. "spec_maker"),
    -- ["os3"] = require(on_slash_commands .. "todolist_maker"),
    ["draw"] = require(on_slash_commands .. "excalidraw"),

    -- off action palette & keymap only
    ["Review Commit"] = require(on_keymaps .. "review_commit"),
    ["Generate Commit Message"] = require(on_keymaps .. "generate_commit_msg"),
    ["Simplify Paragraph"] = require(on_keymaps .. "simplify_paragraph"),

    -- on action palette
    ["Analyze git status         "] = require(on_palette .. "analyze_git_status"),
    ["Generate English study note"] = require(on_palette .. "generate_english_study_note"),
}
