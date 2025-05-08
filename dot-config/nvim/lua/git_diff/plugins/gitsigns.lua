return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		update_debounce = 10,
		watch_gitdir = {
			follow_files = true,
		},
		auto_attach = true,
		attach_to_untracked = true,
		sign_priority = 20, -- dignostics 보다 후순위로 해야

		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "?" },
		},
		numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
		signs_staged_enable = true,
		signs_staged = {
			add = { text = "✔" },
			change = { text = "✔" },
			delete = { text = "✔" },
			topdelete = { text = "✔" },
			changedelete = { text = "✔" },
			untracked = { text = "✔" },
		},
		preview_config = {
			-- Options passed to nvim_open_win
			border = require("utils").borders.git_preview,
			style = "minimal",
			relative = "cursor",
			row = 0,
			col = 1,
		},
		on_attach = function()
			local gs = package.loaded.gitsigns

			-- Git 상태 변경 후 nvim-tree 갱신
			vim.api.nvim_create_autocmd("User", {
				pattern = "GitSignsUpdate",
				callback = function()
					require("nvim-tree.api").tree.reload()
				end,
			})

			vim.keymap.set({ "n", "v" }, "cn", function()
				gs.nav_hunk("next", { target = "all" })
			end, { noremap = true, silent = true })
			vim.keymap.set({ "n", "v" }, "cp", function()
				gs.nav_hunk("prev", { target = "all" })
			end, { noremap = true, silent = true })
		end,
	},
}
