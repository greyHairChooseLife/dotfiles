return {
    url = "https://codeberg.org/andyg/leap.nvim",
    lazy = false,
    dependencies = {
        -- TODO: dot(.) repeat을 위한 의존성인데, 이거 어떻게 활용하나?
        -- https://www.lazyvim.org/extras/editor/leap#vim-repeat
        "tpope/vim-repeat",
    },
    opts = {
        case_sensitive = false,
    },
    config = function(_, opts)
        local leap = require("leap")
        leap.setup(opts)

        -- fold 상태 저장/복원: leap 사용 중 closed fold를 임시로 열어서 jump 가능하게 함
        -- local saved_folds = {}

        -- vim.api.nvim_create_autocmd("User", {
        --     pattern = "LeapEnter",
        --     callback = function()
        --         saved_folds = {}
        --         local total = vim.fn.line("$")
        --         local i = 1
        --         while i <= total do
        --             local fc = vim.fn.foldclosed(i)
        --             if fc == i then
        --                 local fe = vim.fn.foldclosedend(i)
        --                 table.insert(saved_folds, { start = i, finish = fe })
        --                 i = fe + 1
        --             else
        --                 i = i + 1
        --             end
        --         end
        --         -- 역순으로 열어야 중첩 fold도 정확히 처리됨
        --         for j = #saved_folds, 1, -1 do
        --             vim.cmd(saved_folds[j].start .. "foldopen")
        --         end
        --     end,
        -- })
        --
        -- vim.api.nvim_create_autocmd("User", {
        --     pattern = "LeapLeave",
        --     callback = function()
        --         -- 역순으로 닫아야 중첩 fold가 올바르게 복원됨
        --         for j = #saved_folds, 1, -1 do
        --             local lnum = saved_folds[j].start
        --             if lnum <= vim.fn.line("$") then vim.cmd(lnum .. "foldclose") end
        --         end
        --         saved_folds = {}
        --     end,
        -- })
    end,
}
