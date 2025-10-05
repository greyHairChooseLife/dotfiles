return {
	"L3MON4D3/LuaSnip",
	lazy = true,
	dependencies = {
		{
			"rafamadriz/friendly-snippets",
			config = function()
				-- MEMO:: turn on if I need
				-- require("luasnip.loaders.from_vscode").lazy_load()
				-- require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
			end,
		},
	},
	opts = {
		history = true,
		delete_check_events = "TextChanged",
	},
	config = function()
		-- Uncomment these to enable key bindings
		vim.keymap.set({ "i", "s" }, "<Tab>", function()
			if require("luasnip").expand_or_jumpable() then
				require("luasnip").expand_or_jump()
			else
				vim.api.nvim_input("<C-V><Tab>")
			end
		end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
			require("luasnip").jump(-1)
		end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<C-E>", function()
			if require("luasnip").choice_active() then
				require("luasnip").change_choice(1)
			end
		end, { silent = true })
	end,
}
