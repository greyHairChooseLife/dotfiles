local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- DEPRECATED:: 2025-02-06, which-key
-- log 확인
-- map("n", "<leader>gl<Space>", "<cmd>GV<CR>")
-- map("n", "<leader>gla", "<cmd>GV --all<CR>")
-- map("n", "<leader>glr", "<cmd>GV reflog<CR>")
-- map("n", "<leader>glf", "<cmd>GV!<CR>")

-- git status 관리
map("n", ",g", "<cmd>G<CR>") -- shortcut
map("n", "<leader>cc", "<cmd>silent G commit<CR>", { silent = true }) -- 즉시 커밋, 버퍼가 상단이 아니라 우측에서 열리도록 하고 view는 유지
map("n", "<leader>ce", "<cmd>silent G commit --amend<CR>", { silent = true })

-- DEPRECATED:: 2025-02-07, which-key
-- map("n", ",vfd", ":vert diffsplit ") -- 파일 비교
-- map("n", ",vd", VDiffSplitOnTab) -- 현재 버퍼 gitdiff 확인

-- TODO: (Fetch가 아니라)PR을 받아서 (현재 최신과)비교하는것 추가
-- DEPRECATED:: 2025-02-07, which-key
-- map("n", "<leader>reb", ":DiffviewFileHistory --range=<Tab>") -- 특정 브랜치, 선택해야 한다.
-- map("n", "<leader>re<Space>", "<cmd>DiffviewFileHistory<CR>") -- 현재 브랜치 히스토리
-- map("n", "<leader>rea", "<cmd>DiffviewFileHistory --all<CR>") -- 모든 커밋 히스토리
-- map("n", "<leader>ref", "<cmd>DiffviewFileHistory %<CR>") -- current file only, commit history
-- map("n", "<leader>reF", "<cmd>DiffviewFileHistory --reverse --range=HEAD...FETCH_HEAD<CR>") -- something fetched
-- map("n", "<leader>res", "<cmd>DiffviewOpen --staged<CR>") -- review staged
-- map("n", "<leader>rew", "<cmd>DiffviewOpen<CR>") -- review working status, staged + unstaged
-- map("v", "<leader>re", DiffviewOpenWithVisualHash) -- gbl로 gitsigns blame line을 확인하고, 커밋의 변경사항을 확인

-- GITSIGNS
-- DEPRECATED:: 2025-02-06, which-key
-- map("n", "<leader><leader>d", function()
-- 	vim.cmd("Gitsigns toggle_word_diff")
-- 	vim.cmd("Gitsigns toggle_linehl")
-- end)
map("n", "gsth", "<cmd>Gitsigns stage_hunk | NvimTreeRefresh<CR>") -- stage hunk
map("v", "gsth", Visual_stage) -- stage hunk
map("v", "gstu", Visual_undo_stage) -- stage hunk
map("n", "gstb", "<cmd>Gitsigns stage_buffer | NvimTreeRefresh<CR>") -- stage buffer
map("n", "greh", "<cmd>Gitsigns reset_hunk | NvimTreeRefresh<CR>") -- reset hunk, de-active
map("v", "greh", Visual_reset) -- reset hunk, de-active
map("n", "gpre", "<cmd>Gitsigns preview_hunk<CR>") -- show diff
map("n", "gbl", "<cmd>Gitsigns blame_line<CR>") -- show diff
