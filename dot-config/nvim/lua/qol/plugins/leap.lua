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
}
