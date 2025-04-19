return {
	"rmagatti/auto-session",
	cmd = { "SessionSearch", "SessionSave" },
	opts = {
		log_level = "error",
		auto_session_suppress_dirs = { "~/", "~/test", "~/Downloads", "/*" },
		session_lens = {
			buftypes_to_ignore = {}, -- list of buffer types what should not be deleted from current session
			load_on_setup = true,
			-- theme = "ivy", -- default is dropdown
			theme_conf = {
				border = true,
			},
			previewer = false,
			path_dispaly = { "shorten" },
		},
		auto_save_enabled = false,
	},
}
