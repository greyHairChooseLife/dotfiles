local path = "AI.codecompanion.prompt_library."

return {
    -- on slash command
    ["draw"] = require(path .. "excalidraw"),

    -- on keymap
    ["Review Commit"] = require(path .. "review_commit"),
    ["Generate Commit Message"] = require(path .. "generate_commit_msg"),
    ["Simplify Paragraph"] = require(path .. "simplify_paragraph"),
    ["Translate Eng & Kor"] = require(path .. "translator"),
    ["Polish English"] = require(path .. "polish_english"),

    -- on action palette
    ["Analyze git status"] = require(path .. "analyze_git_status"),
    ["Generate English-Study Note"] = require(path .. "generate_english_study_note"),
}
