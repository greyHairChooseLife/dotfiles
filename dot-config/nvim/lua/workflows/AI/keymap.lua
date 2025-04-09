local wk_map = require("utils").wk_map
local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- >>>>>>>>>>>>>>>>> context provider
map("n", ",y", Save_entire_buffer_to_register_for_AI_prompt, opt)
map("v", ",y", Save_visual_selection_to_register_for_AI_prompt, opt)
map("v", ",r", Save_buf_ref_of_visual_selection_to_register_for_AI_prompt, opt)
-- >>>>>>>>>>>>>>>>> context provider

-- DEPRECATED:: 2025-02-04, which-key
-- -- >>>>>>>>>>>>>>>>> Avante
-- map({ "n", "v" }, "<leader>aa", "<cmd>AvanteToggle<cr>", opt)
-- map("n", "<leader>af", "<cmd>AvanteFocus<cr>", opt)
-- -- >>>>>>>>>>>>>>>>> Avante

-- >>>>>>>>>>>>>>>>> Copilot
-- DEPRECATED:: 2025-03-10
-- map("i", "<A-Down>", "<Plug>(copilot-accept-line)", opt)
-- map("i", "<C-e>", "<Plug>(copilot-dismiss)", opt)
-- map("i", "<C-y>", 'copilot#Accept("\\<CR>")', {
-- 	expr = true,
-- 	replace_keycodes = false,
-- })
-- map("i", "<A-j>", "<Plug>(copilot-accept-line)", opt)
-- map("i", "<A-k>", "<Plug>(copilot-suggest)", opt)
-- map("i", "<A-l>", "<Plug>(copilot-accept-word)", opt)
-- map("i", "<A-p>", "<Plug>(copilot-previous)", opt)
-- map("i", "<A-n>", "<Plug>(copilot-next)", opt)
map("i", "<A-l>", function()
	require("copilot.suggestion").accept_word() -- virtual text가 자꾸 사라져서 짜증난다
	require("copilot.suggestion").next()
end, opt)
-- <<<<<<<<<<<<<<<<< Copilot

-- MEMO:: CodeCompanion
local cdc_func = require("workflows.AI.function.codecompanion")
wk_map({
	["<leader>c"] = {
		group = "  CodeCompanion",
		order = { "i", "u", "c", "t", "f", "a" },
		["i"] = { cdc_func.inspect, desc = "inspect New", mode = { "n" } },
		["u"] = { cdc_func.test, desc = "test", mode = { "n", "v" } },

		["c"] = { cdc_func.create_new, desc = "create new", mode = { "n" } },
		["t"] = { cdc_func.toggle_last_chat, desc = "toggle", mode = { "n", "v" } },
		["f"] = { cdc_func.focus_last_chat, desc = "focus", mode = { "n" } },
		["a"] = { cdc_func.add_buffer_reference, desc = "add buffer reference", mode = { "n", "v" } },

		["C"] = { "<cmd>CopilotChatCommit<CR>", desc = "write commitm msg", mode = { "n" } },
		["p"] = { "<cmd>CopilotChatPrompts<CR>", desc = "prompts", mode = { "n" } },
	},
})
wk_map({
	["<leader>c"] = {
		group = "  CodeCompanion",
		order = { "f" },
		["f"] = { ChatWithCopilotOpen_Visual, desc = "focus visual", mode = { "v" } },
	},
})
wk_map({
	["<leader>ce"] = {
		group = "Prefill",
		order = { "1", "2", "3", "4", "5", "6", "7", "r", "R" },
		["1"] = { "<cmd>CopilotChatExplain<CR>", desc = "코드 설명", mode = { "n", "v" } },
		["2"] = { "<cmd>CopilotChatReview<CR>", desc = "코드 리뷰", mode = { "n", "v" } },
		["3"] = { "<cmd>CopilotChatFix<CR>", desc = "버그 해결", mode = { "n", "v" } },
		["4"] = { "<cmd>CopilotChatBetterNamings<CR>", desc = "변수명 개선", mode = { "n", "v" } },
		["5"] = { "<cmd>CopilotChatOptimize<CR>", desc = "코드 최적화", mode = { "n", "v" } },
		["6"] = { "<cmd>CopilotChatDocs<CR>", desc = "docstring 추가", mode = { "n", "v" } },
		["7"] = { "<cmd>CopilotChatTests<CR>", desc = "테스트 작성", mode = { "n", "v" } },
		["r"] = { "<cmd>CopilotChatReviewCommit<CR>", desc = "커밋 리뷰", mode = { "n", "v" } },
		["R"] = { "<cmd>CopilotChatReviewCommitDeep<CR>", desc = "커밋 리뷰 Deep", mode = { "n", "v" } },
	},
})
