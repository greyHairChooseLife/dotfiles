return {
	enabled = true,
	opts = {
		-- Keymap to open history from chat buffer (default: gh)
		keymap = "gH",
		-- Automatically generate titles for new chats
		auto_generate_title = true,
		---On exiting and entering neovim, loads the last chat on opening chat
		continue_last_chat = false,
		---When chat is cleared with `gx` delete the chat from history
		delete_on_clearing_chat = true,
		-- Picker interface ("telescope" or "default")
		picker = "snacks",
		---Enable detailed logging for history extension
		enable_logging = false,
		---Directory path to save the chats
		dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
	},
}
