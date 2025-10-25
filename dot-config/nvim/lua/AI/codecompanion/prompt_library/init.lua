local on_slash_commands = "AI.codecompanion.prompt_library.on_slash_commands."
local on_keymaps = "AI.codecompanion.prompt_library.on_keymaps."
local on_palette = "AI.codecompanion.prompt_library.on_palette."

return {
    -- MEMO:: touch default
    ["Generate a Commit Message"] = {
        opts = { is_slash_cmd = false, short_name = "[deprecated] commit" },
    },

    -- MEMO:: custom
    -- 1. slash_cmd로 사용하든 뭐든 일단 등록을 해야 사용할 수 있다. 여기가 유일한 등록 지점.
    -- 2. is_default 옵션을 사용해 action palette에 등록할지 관리 가능.
    --

    -- off action palette & slash_command only
    ["os1"] = require(on_slash_commands .. "get_full_git_status_reference"),
    ["os2"] = require(on_slash_commands .. "spec_maker"),
    ["os3"] = require(on_slash_commands .. "todolist_maker"),

    -- off action palette & keymap only
    ["ok1"] = require(on_keymaps .. "review_commit"),
    ["ok2"] = require(on_keymaps .. "generate_commit_msg"),
    ["ok3"] = require(on_keymaps .. "simplify_paragraph"),

    -- on action palette
    ["Analyze git status         "] = require(on_palette .. "analyze_git_status"),
    ["Generate English study note"] = require(on_palette .. "generate_english_study_note"),
}
