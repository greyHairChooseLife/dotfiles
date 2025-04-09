## 유용한 아이콘

```txt
#좌측
▏ ▎ ▍ ▌ ▋ ▊ ▉ █

#우측
▕

#중앙
┃│┆

#상하
▔ ▁

#명도
░ ▒ ▓

#특수
▖ ▗ ▘ ▙ ▚ ▛ ▜ ▝ ▞ ▟
```


## 짤막 커맨드


- 현재 윈도우의 highlight 알아내기
  `lua print(vim.inspect(vim.api.nvim_get_hl(0, { name = "FoldColumn" })))`


- ```lua
  -- Vim 명령줄 약어(cabbrev)를 등록하는 코드
  -- 사용자가 :cc 를 입력하면 자동으로 :CodeCompanion 으로 확장됨
  -- 명령어 입력을 간편하게 줄여주는 alias 역할

  vim.cmd([[cab cc CodeCompanion]])
  ```



## plugin config example 

### "ibhagwan/fzf-lua",

- ```
  return {
    "ibhagwan/fzf-lua",
    branch = "main",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      -- { "tpope/vim-fugitive" },
    },
    keys = {
      {
        "<leader>/c",
        function()
          require("fzf-lua").commands()
        end,
        desc = "Search commands",
      },
      {
        "<leader>/C",
        function()
          require("fzf-lua").command_history()
        end,
        desc = "Search command history",
      },
      {
        "<leader>sl",
        function()
          require("fzf-lua").live_grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>sc",
        function()
          require("lt.plugins.fzf.functions").search_config()
        end,
        desc = "Search neovim config",
      },
      {
        "<leader>s~",
        function()
          require("fzf-lua").files({
            prompt = "Profile >",
            cwd = "$HOME",
          })
        end,
        desc = "Search profile",
      },
      {
        "<leader>pf",
        function()
          require("fzf-lua").files()
        end,
        desc = "Find files",
      },
      {
        "<leader>pF",
        function()
          require("lt.plugins.fzf.functions").search_project_files()
        end,
        desc = "Find files in another project",
      },
      {
        "<leader>pd",
        function()
          local current_file_path = vim.fn.expand("%:p")
          local directory = vim.fn.fnamemodify(current_file_path, ":h")
          require("fzf-lua").files({
            prompt = "Navigation Bar >",
            cwd = directory,
          })
        end,
        desc = "Navigation bar",
      },
      {
        "<leader>po",
        function()
          require("fzf-lua").oldfiles()
        end,
        desc = "Find files",
      },
      {
        "<leader>pg",
        function()
          require("fzf-lua").git_files()
        end,
        desc = "Find git files",
      },
      {
        "<leader>/h",
        function()
          require("fzf-lua").highlights()
        end,
        desc = "Search highlights",
      },
      {
        "<leader>/r",
        function()
          require("fzf-lua").registers()
        end,
        desc = "Search registers",
      },
      {
        "<leader>/M",
        function()
          require("fzf-lua").marks()
        end,
        desc = "Search marks",
      },
      {
        "<leader>/k",
        function()
          require("fzf-lua").keymaps()
        end,
        desc = "Search keymaps",
      },
      {
        "<leader>/t",
        function()
          require("fzf-lua").treesitter()
        end,
        desc = "Search treesitter",
      },
      {
        "<leader>g/b",
        function()
          require("fzf-lua").git_branches()
        end,
        desc = "Search git branches",
      },
      {
        "<leader>g/c",
        function()
          require("fzf-lua").git_commits()
        end,
        desc = "Search git commits",
      },
      {
        "<leader>g/C",
        function()
          require("fzf-lua").git_bcommits()
        end,
        desc = "Search git buffer commits",
      },
      {
        "<leader>bc",
        function()
          require("fzf-lua").git_bcommits()
        end,
        desc = "Search git buffer commits",
      },
      {
        "<leader>bl",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Search buffers",
      },
      {
        "<leader>//",
        function()
          require("fzf-lua").resume()
        end,
        desc = "Resume FZF",
      },
    },
    config = function()
      require("fzf-lua").setup({
        keymap = {
          fzf = {
            ["CTRL-Q"] = "select-all+accept",
          },
        },
        files = {
          git_icons = false,
        },
      })
      require("fzf-lua").register_ui_select()
    end,
  }
  ```

- ```
  local M = {}

  M.search_config = function()
    require("fzf-lua").files({
      prompt = "Config >",
      cwd = "$HOME/.local/share/chezmoi",
    })
  end

  local repo_directory = "$HOME/repos"
  local function get_projects()
    local repo_directories = vim.fs.dir(repo_directory, { depth = 1, type = "directory" })

    local projects = {}
    for name, type in repo_directories do
      if type == "directory" then
        projects[#projects + 1] = vim.fs.normalize(vim.fs.joinpath(repo_directory, name))
      end
    end

    return projects
  end

  M.switch_project = function()
    local projects = get_projects()

    require("fzf-lua").fzf_exec(projects, {
      prompt = "Projects >",
      actions = {
        ["default"] = function(e)
          local path = e[1]
          vim.cmd.cd(path)
          -- vim.cmd("ProjectRoot '" .. path .. "'")
          vim.cmd("Oil " .. path)
        end,
      },
    })
  end

  M.search_project_files = function()
    local projects = get_projects()

    require("fzf-lua").fzf_exec(projects, {
      prompt = "Projects >",
      actions = {
        ["default"] = function(e)
          local path = e[1]

          require("fzf-lua").files({
            cwd = path,
          })
        end,
      },
    })
  end

  return M
  ```

### "folke/edgy.nvim",

- ```
  return {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {
      bottom = {
        -- {
        --   ft = "toggleterm",
        --   size = { height = 0.4 },
        --   -- exclude floating windows
        --   filter = function(buf, win)
        --     return vim.api.nvim_win_get_config(win).relative == ""
        --   end,
        -- },
        { ft = "qf", title = "QuickFix" },
        {
          ft = "help",
          size = { height = 20 },
          -- only show help buffers
          filter = function(buf)
            return vim.bo[buf].buftype == "help"
          end,
        },
        { ft = "neotest-output-panel", title = "Neotest OutputPanel", size = { height = 0.3 } },
        {
          ft = "toggleterm",
          title = "Term",
          size = { height = 0.4 },
          filter = function(buf)
            return not vim.b[buf].lazyterm_cmd
          end,
        },
      },
      left = {
        { ft = "neotest-summary", title = "Neotest Summary", size = { width = 0.4 } },
      },
      right = {
        { ft = "codecompanion", title = "Code Companion Chat", size = { width = 0.4 } },
        { ft = "aerial", title = "Symbols", size = { width = 0.2 } },
        "Trouble",
      },
    },
  }
  ```
