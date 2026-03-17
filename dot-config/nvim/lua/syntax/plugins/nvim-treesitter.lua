return {
    -- TODO: Lazyvim에서 가져오긴 했다만, 뭘 의미하는걸까.. 하나하나 살펴볼 필요가 있다.
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    init = function(plugin)
        -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
        -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
        -- no longer trigger the **nvim-treesitter** module to be loaded in time.
        -- Luckily, the only things that those plugins need are the custom queries, which we make available
        -- during startup.
        require("lazy.core.loader").add_to_rtp(plugin)
        pcall(require, "nvim-treesitter.query_predicates")
    end,
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
        { "<Right>", desc = "Increment Selection" },
        { "<Left>", desc = "Decrement Selection", mode = "x" },
    },
    opts_extend = { "ensure_installed" },
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
        highlight = { enable = true },
        auto_install = true,
        indent = { enable = true },
        ensure_installed = {
            "asm",
            "awk",
            "bash",
            "cmake",
            "cpp",
            "c",
            "css",
            "csv",
            "desktop",
            "diff",
            "disassembly",
            "dockerfile",
            "d",
            "editorconfig",
            "gitattributes",
            "gitcommit",
            "git_config",
            "gitignore",
            "git_rebase",
            "htmldjango",
            "html",
            "http",
            "ini",
            "javascript",
            "jq",
            "jsdoc",
            "json5",
            "jsonc",
            "json",
            "latex",
            "luadoc",
            "luap",
            "lua",
            "make",
            "markdown_inline",
            "markdown",
            "nginx",
            "pem",
            "perl",
            "printf",
            "prisma",
            "prolog",
            "python",
            "query",
            "readline",
            "regex",
            "requirements",
            "robots",
            "rust",
            "sql",
            "ssh_config",
            "terraform",
            "tmux",
            "toml",
            "tsx",
            "typescript",
            "vimdoc",
            "vim",
            "xml",
            "xresources",
            "yaml",
        },
        incremental_selection = {
            enable = true,
            -- "vimwiki"는 안되지만 "markdown"으로 둘 다 커버된다.
            -- "vim"은 CmdWindow에서 커맨드 즉시 실행하기 위한것
            disable = { "markdown", "vim" },
            keymaps = {
                init_selection = "<CR>",
                scope_incremental = "<CR>",
                node_incremental = "<TAB>",
                node_decremental = "<S-TAB>",
            },
        },
        textobjects = {
            select = {
                enable = true,
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ["ia"] = "@parameter.inner",
                    ["aa"] = "@parameter.outer",
                    ["ii"] = "@conditional.inner",
                    ["ai"] = "@conditional.outer",
                    ["il"] = "@loop.inner",
                    ["al"] = "@loop.outer",
                    ["ic"] = "@class.inner",
                    ["ac"] = "@class.outer",
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["it"] = "@comment.inner",
                    ["at"] = "@comment.outer",
                },
            },
            move = {
                enable = true,
                goto_next_start = {
                    ["]f"] = "@function.outer",
                    ["]c"] = "@class.outer",
                    ["]a"] = "@parameter.inner",
                },
                goto_next_end = {
                    ["]F"] = "@function.outer",
                    ["]C"] = "@class.outer",
                    ["]A"] = "@parameter.inner",
                },
                goto_previous_start = {
                    ["[f"] = "@function.outer",
                    ["[c"] = "@class.outer",
                    ["[a"] = "@parameter.inner",
                },
                goto_previous_end = {
                    ["[F"] = "@function.outer",
                    ["[C"] = "@class.outer",
                    ["[A"] = "@parameter.inner",
                },
            },
        },
    },
    ---@param opts TSConfig
    config = function(_, opts)
        require("nvim-treesitter").setup(opts)
        vim.treesitter.language.register("markdown", "vimwiki")
    end,
}
