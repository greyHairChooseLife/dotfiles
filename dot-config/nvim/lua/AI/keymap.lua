local wk_map = require("utils").wk_map
local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- MEMO:: context provider
map("n", ",y", Save_entire_buffer_to_register_for_AI_prompt, opt)
map("v", ",y", Save_visual_selection_to_register_for_AI_prompt, opt)
map("v", ",r", Save_buf_ref_of_visual_selection_to_register_for_AI_prompt, opt)

-- MEMO:: copilot.lua
map("i", "<A-l>", function()
    require("copilot.suggestion").accept_word() -- virtual text가 자꾸 사라져서 짜증난다
    require("copilot.suggestion").next()
end, opt)

-- MEMO:: STT & TTS
map("n", ",v", "<cmd>Vocal<CR>", opt)
map("v", ",v", "<cmd>TTS<CR>", opt)

-- MEMO:: CodeCompanion
local cdc_func = require("AI.codecompanion.utils.general")
local predefined = {
    explain = "/explain",
    fix = "/fix",
    lsp = "/lsp",
    code_workflow = "/cw",
    review_commit = "/review_commit",
    generate_commit_msg = "/generate_commit_msg",
    simplify_paragraph = "/simplify_paragraph",
    -- DEPRECATED:: 2025-05-09
    -- agsfc = "/analyze_git_status_for_commits",
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
    ["<leader>c"] = {
        group = "  CodeCompanion",
        order = { "c", "h", "t", "f", "a", "A", "e", "C" },
        -- ["i"] = { cdc_func.inspect, desc = "inspect New", mode = { "n" } },
        -- ["u"] = { cdc_func.test, desc = "test", mode = { "n", "v" } },
        ["c"] = { cdc_func.create_new, desc = "create new", mode = { "n", "v" } },
        ["h"] = { "<cmd>CodeCompanionHistory<CR>", desc = "history", mode = { "n" } },
        ["t"] = { cdc_func.toggle_last_chat, desc = "toggle", mode = { "n", "v" } },
        ["f"] = {
            function()
                local mode = vim.fn.mode()
                if mode == "n" then
                    cdc_func.focus_last_chat()
                else
                    cdc_func.create_new() -- 새로운 채팅에서 visual 레퍼런스 가지고 시작
                    -- cdc_func.add_buffer_reference() -- 마지막 채팅에서 visual 레퍼런스 가지고 시작
                end
            end,
            desc = "focus",
            mode = { "n", "v" },
        },
        ["a"] = { cdc_func.add_buffer_reference, desc = "add buffer reference", mode = { "n", "v" } },
        ["A"] = { cdc_func.add_tab_buffers_reference, desc = "add All buffers in Tab reference", mode = { "n", "v" } },
        ["C"] = { gen_command("pre", predefined.generate_commit_msg), desc = "generate commitm msg", mode = { "n" } },
    },
})

wk_map({
    ["<leader>ce"] = {
        group = "Prefill",
        order = { "d", "e", "l", "f", "g", "n", "i", "I", "s", "R" },
        ["e"] = { gen_command("pre", predefined.explain), desc = "explain", mode = { "v" } },
        ["l"] = { gen_command("pre", predefined.lsp), desc = "lsp", mode = { "v" } },
        ["f"] = { gen_command("pre", predefined.fix), desc = "fix", mode = { "v" } },
        ["g"] = { gen_command("pre", predefined.code_workflow), desc = "  generate code", mode = { "n" } },
        -- DEPRECATED:: 2025-05-08
        -- to action palette only
        -- ["c"] = {
        -- 	gen_command("pre", predefined.agsfc),
        -- 	desc = "analyze: staged & unstaged & untracked",
        -- 	mode = { "n" },
        -- },
        ["R"] = {
            gen_command("pre", predefined.review_commit),
            desc = "Review commit: HEAD or CommitHash",
            mode = { "n", "v" },
        },
        ["s"] = {
            gen_command("pre", predefined.simplify_paragraph),
            desc = "simplify paragraph",
            mode = { "v" },
        },

        ["n"] = { gen_command("inline", inline.better_naming), desc = "󰊈 better naming", mode = { "v" } },
        ["d"] = { gen_command("inline", inline.docstring), desc = "󰊈 docstring", mode = { "v" } },

        ["i"] = { gen_command("chat", chat.improve_readability), desc = "improve readability", mode = { "v" } },
        ["I"] = { gen_command("chat", chat.cra), desc = "improve readability: prompt from avante", mode = { "v" } },
    },
})
