local utils = require("utils")
local map = vim.keymap.set
local opt = { noremap = true, silent = true }
local wk_map = utils.wk_map

-- MEMO:: 이거 없으면 일부 터미널에서 한글 입력시 문제가 발생한다.
-- (의도) "저는 오늘 저녁으로 김치를 먹었습니다."
-- (결과) "저 는오 늘저녁으 로김치 를먹었습니다."
-- map("i", "<Space>", function()
-- 	-- TODO:: 이거 input-method가 한글로 설정된 경우로 한정할 수 있겠다. 그럼 nerd-dictation같은거 잘 될듯
-- 	vim.defer_fn(function()
-- 		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Space>", true, false, true), "n", true)
-- 	end, 20)
-- end, opt)

map("n", "`g", "<cmd>wincmd p<CR>") -- focus previous window & cursor position
map("v", "p", '"_dP') -- paste without yanking in visual mode
-- map("v", "x", '"_d') -- delete without yanking in visual mode
map("v", "<leader>s", SearchWithBrowser, opt)

-- 앞글자 대문자로 변환
map({ "n", "v" }, "gu", function()
    utils.save_cursor_position()
    vim.cmd("normal! lbvU")
    utils.restore_cursor_position()
end) -- CamelCase

map({ "n", "v" }, ";", ":")
map({ "n", "v" }, ":", ";")
map({ "n", "v" }, "Q", ",")

map({ "n", "v" }, "zo", "za") -- toggle fold uni-key
-- map({ "n", "v" }, "zz", "zz5<C-e>") -- toggle fold uni-key
-- map({ "n", "v" }, "zZ", "zz", { noremap = true }) -- toggle fold uni-key
map({ "n", "v" }, "gH", "0") -- move cursor
map({ "n", "v" }, "gh", "^") -- move cursor
map({ "n", "v" }, "gl", "$") -- move cursor
map({ "n", "v" }, "gL", "$") -- move cursor
map("n", "'", ToggleHilightSearch)
map("v", "'", HilightSearch)
-- These add {count}j/k into jumplist so it can jump back with c-o/i
-- map("n", "j", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
-- map("n", "k", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })

map("n", "vv", "viw") -- easy visual block for word
map("v", "v", "<Esc>")

map({ "n", "v", "i", "c" }, "<leader>t", "<cmd>TTimerlyToggle<cr>")

map({ "n", "v" }, "Z", "<Cmd>Focus<CR>")
map("v", ",<Space>", ":FocusHere<CR>", opt)
map("n", ",<Space>", "<cmd>FocusClear<CR>", opt)
map("n", "<Space><Space>", function()
    vim.cmd("NoiceDismiss")
    BlinkCursorLine()
end)
map("n", "ypa", function() utils.copy_path("absolute") end)
map("n", "ypr", function() utils.copy_path("relative") end)
map("n", "ypf", function() utils.copy_path("filename") end)
map("n", "ypd", function() utils.copy_path("directory") end)

map("i", "cc<Enter>", function() vim.api.nvim_input("<Esc>cc") end)
map("i", "zz", function() vim.api.nvim_input("<Esc>zzA") end)

map("i", "<M-b>", "<C-Left>")
map("i", "<M-f>", "<C-Right>")
map("i", "<C-b>", "<Left>")
map("i", "<C-f>", "<Right>")
map("i", "<C-a>", "<Home>")
map("i", "<C-e>", "<End>")
map("i", "<C-d>", "<Del>")
map("c", "<M-b>", "<C-Left>")
map("c", "<M-f>", "<C-Right>")
map("c", "<C-a>", "<Home>")
map("c", "<C-e>", "<End>")
map("c", "<C-d>", "<Del>")

-- TODO: <esc> 시뮬레이션 방법을 통일(검증 필요)하고, 함수로 만들어 재사용하자.
-- Easy Escape
map({ "i", "c" }, ";j<Space>", function()
    vim.api.nvim_input("<C-c>") -- cmdwin에서는 <Esc>로 동작하도록
end, { noremap = true })
map({ "i", "c" }, "gq", function()
    vim.api.nvim_input("<C-c>") -- cmdwin에서는 <Esc>로 동작하도록
end, { noremap = true })
map({ "i", "c" }, ";ㅓ<Space>", function()
    vim.api.nvim_input("<Esc>") -- 실제 <Esc> 입력을 강제 실행
    os.execute("xdotool key Escape") -- 영어 입력 모드로 전환 (kime에 ESC 입력 보내기), keyboard layout to English
end, { noremap = true })
-- jk or kj as well
map({ "i", "c" }, "jk", function()
    vim.api.nvim_input("<C-c>") -- cmdwin에서는 <Esc>로 동작하도록
end, { noremap = true })
map({ "i", "c" }, "kj", function()
    vim.api.nvim_input("<C-c>") -- cmdwin에서는 <Esc>로 동작하도록
end, { noremap = true })
map({ "i", "c" }, "ㅓㅏ", function()
    vim.api.nvim_input("<Esc>") -- 실제 <Esc> 입력을 강제 실행
    os.execute("xdotool key Escape") -- 영어 입력 모드로 전환 (kime에 ESC 입력 보내기), keyboard layout to English
end, { noremap = true })
map({ "i", "c" }, "ㅏㅓ", function()
    vim.api.nvim_input("<Esc>") -- 실제 <Esc> 입력을 강제 실행
    os.execute("xdotool key Escape") -- 영어 입력 모드로 전환 (kime에 ESC 입력 보내기), keyboard layout to English
end, { noremap = true })
map("n", "ㅗ", function()
    os.execute("xdotool key Escape") -- 영어 입력 모드로 전환 (kime에 ESC 입력 보내기), keyboard layout to English
    vim.api.nvim_input("h")
end, opt)
map("n", "ㅓ", function()
    os.execute("xdotool key Escape") -- 영어 입력 모드로 전환 (kime에 ESC 입력 보내기), keyboard layout to English
    vim.api.nvim_input("j")
end, opt)
map("n", "ㅏ", function()
    os.execute("xdotool key Escape") -- 영어 입력 모드로 전환 (kime에 ESC 입력 보내기), keyboard layout to English
    vim.api.nvim_input("k")
end, opt)
map("n", "ㅣ", function()
    os.execute("xdotool key Escape") -- 영어 입력 모드로 전환 (kime에 ESC 입력 보내기), keyboard layout to English
    vim.api.nvim_input("l")
end, opt)

map({ "n", "v" }, "<C-e>", "2<C-e>")
map({ "n", "v" }, "<C-y>", "2<C-y>")
map("n", ",.<ESC>", "<Nop>") -- do nothing
map("n", ",.<Space>", "<Nop>") -- do nothing

-- 선택한 줄 이동
map("x", "<A-k>", ":move '<-2<CR>gv-gv")
map("x", "<A-j>", ":move '>+1<CR>gv-gv")
map("v", "<A-h>", "<gv")
map("v", "<A-l>", ">gv")

-- insert mode 편집 쉽게
map("i", "<C-,>", "<C-Left>")
map("i", "<C-.>", "<C-Right>")

-- snippet
map("i", "cl<cr>", Insert_console_log, opt)
map("v", "cl<cr>", Insert_console_log_Visual, opt)

-- FOLD는 항상  mkview
map("n", "zc", "zc<cmd>mkview<CR>")
map("n", "zo", "zo<cmd>mkview<CR>")
map("n", "zO", "zO<cmd>mkview<CR>")
map("n", "zm", "zm<cmd>mkview<CR>")
map("n", "zM", "zM<cmd>mkview<CR>")
map("n", "zr", "zr<cmd>mkview<CR>")
map("n", "zR", "zR<cmd>mkview<CR>")
map("n", "zf", "zf<cmd>mkview<CR>")
map("n", "zd", "zd<cmd>mkview<CR>")

-- TODO: tmux랑 겹친다. 새로운 keymap 또는 접근법을 찾아야한다.
-- FOLD MOVE
-- map({ "n", "v" }, "<C-j>", "zjw")
-- map({ "n", "v" }, "<C-k>", "zkw")
-- map({ "n", "v" }, "<C-h>", "[zw")
-- map({ "n", "v" }, "<C-l>", "]zw")
-- map({ "n", "v" }, "<C-n>", "%][%zz")
-- map({ "n", "v" }, "<C-p>", "[]%zz")

map("n", "n", function() Safe_search("n") end, opt)
map("n", "N", function() Safe_search("N") end, opt)

-- map("n", ",t", "viw<cmd>Translate ko<CR><Esc>", opt)
map("n", ",t", function()
    vim.api.nvim_input("heak<BS>")
    vim.defer_fn(function() vim.api.nvim_input("<A-o>") end, 10)
end, opt)
map("v", ",t", "<cmd>Translate ko<CR>", opt)

-- { 중괄호 }로 묶인 영역 통째로 복사
map("n", "yY", "va{Vy", opt)

-- MEMO:: Session
wk_map({
    ["<leader>s"] = {
        group = "󱫥  Session",
        order = { "s", "l" },
        ["s"] = { "<cmd>AutoSession save<CR>", desc = "save", mode = "n" },
        ["v"] = {
            function()
                vim.cmd("AutoSession search")
                vim.fn.feedkeys("!json ", "m") -- json 파일에 탭 이름 정보 저장해둠
            end,
            desc = "view",
            mode = "n",
        },
    },
})

-- MEMO:: Run Command
wk_map({
    ["<leader>r"] = {
        group = "  Run Command",
        order = { "r", "R", "u", "x", "c" },
        ["u"] = {
            function() RunBufferWithSh({ selected = true, underline = true }) end,
            desc = "underline",
            mode = "v",
        },
        ["r"] = {
            function()
                local mode = vim.api.nvim_get_mode().mode
                if mode == "n" then
                    RunBufferWithSh()
                else
                    RunBufferWithSh({ selected = true })
                end
            end,
            desc = "run on buffer",
            mode = { "n", "v" },
        },
        ["R"] = {
            function()
                local mode = vim.api.nvim_get_mode().mode
                if mode == "n" then
                    RunBufferWithSh({ cover = true })
                else
                    RunBufferWithSh({ selected = true, cover = true })
                end
            end,
            desc = "run on buffer and cover ",
            mode = { "n", "v" },
        },
        ["x"] = {
            function() CompileAndRun() end,
            desc = "Complile and Execute",
            mode = "n",
        },
        ["c"] = {
            function() TypeCompilecommand() end,
            desc = "Compile",
            mode = "n",
        },
    },
})

-- MEMO:: QuickFix
wk_map({
    ["<Space>q"] = {
        group = "Quick Fix",
        order = { "f", "t", "n", "p" },
        ["f"] = { "<cmd>copen<CR>", desc = "focus", mode = "n" },
        ["t"] = { QF_ToggleList, desc = "toggle", mode = "n" },
        ["n"] = { QF_next, desc = "next", mode = "n" },
        ["p"] = { QF_prev, desc = "prev", mode = "n" },
    },
})
vim.keymap.set("n", "qn", QF_next)
vim.keymap.set("n", "qp", QF_prev)

-- MEMO:: Etc
wk_map({
    [","] = {
        order = { "r", "R", "C" },
        ["r"] = { ReloadLayout, desc = "reload layout", mode = "n" },
        ["R"] = {
            function() ReloadLayout(true) end,
            desc = "reload layout force",
            mode = "n",
        },
        ["C"] = {
            function()
                local word = vim.fn.expand("<cword>")
                vim.api.nvim_feedkeys(":%s/" .. word .. "//g", "n", false)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left><Left>", true, false, true), "n", false)
            end,
            desc = "change",
            mode = "n",
        },
    },
})
