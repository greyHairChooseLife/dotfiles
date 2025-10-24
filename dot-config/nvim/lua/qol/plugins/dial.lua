return {
    "monaqa/dial.nvim",
    keys = { "<C-a>", "<C-x>", "g<C-a>", "g<C-x>", { "<C-a>", mode = "x" }, { "<C-x>", mode = "x" }, { "g<C-a>", mode = "x" }, { "g<C-x>", mode = "x" } },
    -- opts = { },
    config = function()
        local augend = require("dial.augend")
        require("dial.config").augends:register_group({
            default = {
                augend.integer.alias.decimal_int,
                augend.integer.alias.hex,
                augend.integer.alias.octal,
                augend.integer.alias.binary,
                augend.constant.alias.bool,
                augend.constant.alias.alpha,
                augend.constant.alias.Alpha,
                -- uppercase hex number (0x1A1A, 0xEEFE, etc.)
                augend.integer.new({
                    radix = 16,
                    prefix = "0x",
                    natural = true,
                    case = "upper",
                }),

                augend.hexcolor.new({
                    case = "prefer_upper", -- or "lower", "prefer_upper", "prefer_lower", see below
                }),
                -- date with format `yyyy/mm/dd`
                augend.date.new({
                    pattern = "%Y/%m/%d",
                    default_kind = "day",
                    -- if true, it does not match dates which does not exist, such as 2022/05/32
                    only_valid = true,
                    -- if true, it only matches dates with word boundary
                    word = false,
                }),
                augend.constant.new({
                    elements = { "and", "or" },
                    word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
                    cyclic = true, -- "or" is incremented into "and".
                }),
                augend.constant.new({
                    elements = { "&&", "||" },
                    word = false,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "&", "|", "^", "~" },
                    word = false,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "<", ">", "==", "!=" },
                    word = false,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "<=", ">=" },
                    word = false,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "+=", "-=", "*=", "/=", "%=" },
                    word = false,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "+", "-" },
                    word = false,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "++", "--" },
                    word = false,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "yes", "no" },
                    word = false,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "Y", "N" },
                    word = false,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "void", "char", "int", "double" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "break", "continue", "return" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "if", "else" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "stdin", "stdout", "stderr" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "static", "extern", "const", "volatile" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "unsigned", "signed" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "malloc", "calloc", "realloc", "free" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "up", "down", "left", "right" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "read", "write", "open", "close" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "GET", "POST", "PUT", "DELETE", "PATCH" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "async", "await", "sync" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "min", "max", "avg", "sum" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "input", "output" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "request", "response" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "req", "res" },
                    word = true,
                    cyclic = true,
                }),
            },
        })
        vim.keymap.set("n", "<C-a>", function() require("dial.map").manipulate("increment", "normal") end)
        vim.keymap.set("n", "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end)
        vim.keymap.set("n", "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end)
        vim.keymap.set("n", "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end)
        vim.keymap.set("x", "<C-a>", function() require("dial.map").manipulate("increment", "visual") end)
        vim.keymap.set("x", "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end)
        vim.keymap.set("x", "g<C-a>", function() require("dial.map").manipulate("increment", "gvisual") end)
        vim.keymap.set("x", "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end)
    end,
}
