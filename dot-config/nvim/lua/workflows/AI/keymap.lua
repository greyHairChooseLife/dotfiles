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
		order = { "c", "t", "f", "a", "A", "e", "C" },
		-- ["i"] = { cdc_func.inspect, desc = "inspect New", mode = { "n" } },
		-- ["u"] = { cdc_func.test, desc = "test", mode = { "n", "v" } },
		["c"] = { cdc_func.create_new, desc = "create new", mode = { "n" } },
		["t"] = { cdc_func.toggle_last_chat, desc = "toggle", mode = { "n", "v" } },
		["f"] = { cdc_func.focus_last_chat, desc = "focus", mode = { "n" } },
		["a"] = { cdc_func.add_buffer_reference, desc = "add buffer reference", mode = { "n", "v" } },
		["A"] = { cdc_func.add_tab_buffers_reference, desc = "add All buffers in Tab reference", mode = { "n", "v" } },

		-- ["C"] = { "<cmd>CopilotChatCommit<CR>", desc = "write commitm msg", mode = { "n" } },
		["C"] = {
			"<cmd>CodeCompanion /generate_commit_msg<CR>",
			desc = "generate commitm msg",
			mode = { "n" },
		},
	},
})

local predefined = {
	explain = "/explain",
	fix = "/fix",
	lsp = "/lsp",
	code_workflow = "/cw",
	-- analyze_git_status_for_commits
	agsfc = "/analyze_git_status_for_commits",
	review_commit = "/review_commit",
}
local chat = {
	-- improve_readability
	ir = "Review the following code with a strong focus on readability. Suggest improvements to naming, structure, and clarity. If anything is hard to follow, ambiguous, or could be simplified, highlight it and propose cleaner alternatives. Prioritize clean, intuitive, and self-explanatory code.",
	-- code_readability_analysis prompt from avante
	cra = [[
  You must identify any readability issues in the code snippet.
  Some readability issues to consider:
  - Unclear naming
  - Unclear purpose
  - Redundant or obvious comments
  - Lack of comments
  - Long or complex one liners
  - Too much nesting
  - Long variable names
  - Inconsistent naming and code style.
  - Code repetition
  You may identify additional problems. The user submits a small section of code from a larger file.
  Only list lines with readability issues, in the format <line_num>|<issue and proposed solution>
  If there's no issues with code respond with only: <OK>
  Answer in Korean.
]],
}

local inline = {
	better_naming = "Improve this codeblocks by renaming unclear variables and parameters to something more descriptive, based on what they represent or do.",
	docstring = "Please add documentation comments to the selected code, in Korean",
}

---@param mode "pre"|"inline"|"chat"
---@param prompt string
local gen_command = function(mode, prompt)
	local command_by_mode = ""
	if mode == "pre" or mode == "inline" then
		command_by_mode = "CodeCompanion"
	elseif mode == "chat" then
		command_by_mode = "CodeCompanionChat"
	end

	return string.format("<cmd>%s %s<CR>", command_by_mode, prompt)
end

wk_map({
	["<leader>ce"] = {
		group = "Prefill",
		order = { "d", "e", "l", "f", "g", "n", "i", "I", "c", "R" },

		["e"] = { gen_command("pre", chat.explain), desc = "explain", mode = { "v" } },
		["l"] = { gen_command("pre", chat.lsp), desc = "lsp", mode = { "v" } },
		["f"] = { gen_command("pre", chat.fix), desc = "fix", mode = { "v" } },
		["g"] = { gen_command("pre", predefined.code_workflow), desc = "generate code(workflow)", mode = { "n" } },
		["c"] = { gen_command("pre", predefined.agsfc), desc = "analyze: staged/unstaged/untracked", mode = { "n" } },
		["R"] = { gen_command("pre", predefined.review_commit), desc = "커밋 리뷰", mode = { "n", "v" } },

		["n"] = { gen_command("inline", inline.better_naming), desc = "naming variable", mode = { "v" } },
		["d"] = { gen_command("inline", inline.docstring), desc = "docstring", mode = { "v" } },

		["i"] = { gen_command("chat", chat.improve_readability), desc = "improve readability (my own)", mode = { "v" } },
		["I"] = { gen_command("chat", chat.cra), desc = "improve readability (prompt from avante)", mode = { "v" } },
	},
})
