-- CSV file editing
-- https://github.com/hat0uma/csvview.nvim

return {
    "hat0uma/csvview.nvim",
    cmd = "CsvViewEnable",
    ft = { "csv" },
    opts = {
        view = {
            display_mode = "border",
            --- The line number of the header
            --- If this is set, the line is treated as a header. and used for sticky header feature.
            --- see also: `view.sticky_header`
            --- @type integer|false
            header_lnum = 1,

            --- The sticky header feature settings
            --- If `view.header_lnum` is set, the header line is displayed at the top of the window.
            sticky_header = {
                --- Whether to enable the sticky header feature
                --- @type boolean
                enabled = true,

                --- The separator character for the sticky header window
                --- set `false` to disable the separator
                --- @type string|false
                separator = "",
            },
        },
    },
}
