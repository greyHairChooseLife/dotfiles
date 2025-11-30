return {
    "3rd/image.nvim",
    enabled = require("utils").is_alacritty,
    dependencies = { "luarocks.nvim" },
    -- lazy = false,
    ft = { "markdown", "vimwiki" },
    cond = function()
        -- SSH 연결 여부 확인
        local is_ssh = os.getenv("SSH_CLIENT") ~= nil or os.getenv("SSH_TTY") ~= nil or os.getenv("SSH_CONNECTION") ~= nil

        return not is_ssh -- SSH가 아닐 때만 플러그인 로드
    end,
    opts = {
        -- backend = "kitty", -- kitty 터미널로 실행하면 매우 잘 된다. 크기 변경 등 더 매끄럽다.
        backend = "ueberzug",
        integrations = {
            markdown = {
                enabled = true,
                clear_in_insert_mode = true,
                download_remote_images = true,
                only_render_image_at_cursor = true,
                only_render_image_at_cursor_mode = "inline", -- "popup" or "inline", defaults to "popup"
                filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
            },
        },
        -- max_width = nil,
        -- max_height = nil,
        -- max_width_window_percentage = nil,
        -- max_height_window_percentage = 80,
        max_width = 100, -- tweak to preference
        max_height = 70, -- ^
        max_width_window_percentage = math.huge, -- this is necessary for a good experience
        max_height_window_percentage = math.huge,
        window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
        tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- render image files as images when opened
        scale_factor = 1.5,
    },
}
