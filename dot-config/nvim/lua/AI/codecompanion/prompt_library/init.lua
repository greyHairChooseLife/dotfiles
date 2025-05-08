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
	["os1"] = require("AI.codecompanion.prompt_library.on_slash_commands.get_full_git_status_reference"),
	-- off action palette & keymap only
	["ok1"] = require("AI.codecompanion.prompt_library.on_keymaps.review_commit"),
	["ok2"] = require("AI.codecompanion.prompt_library.on_keymaps.generate_commit_msg"),
	-- on action palette
	["Analyze git status"] = require("AI.codecompanion.prompt_library.on_palette.analyze_git_status"),
}
