-- MEMO:: UI config
local font = "D2 Coding" -- defaults to guifont
local foreground_color = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "Normal" }).fg)
local background_color = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "Normal" }).bg)
local outline_color = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "NoteBackground" }).bg)

local bodyStyle = "body { margin: 0; color: " .. foreground_color .. "; }"
local containerStyle = ".container { background-color: " .. outline_color .. "; padding: 2%; }"
local preStyle = "pre { background-color: " .. background_color .. "; }"

-- MEMO:: function
local convert = function(range, opts)
  opts = opts or {}
  local save_to_file = opts.save_to_file or false
  local format = opts.format or "png"     -- png or pdf
  local save_path = opts.save_path or "~" -- Default to home directory
  local filename = opts.filename or "you gotta fix this line"

  local html = require("tohtml").tohtml(0, { range = range, font = font })

  for i, line in pairs(html) do
    if line:match("^%s*body") then
      html[i] = bodyStyle .. containerStyle .. preStyle
    end

    if line:match("^%s*<pre>") then
      html[i] = "<div class='container'><pre>"
    end

    if line:match("^%s*</pre>") then
      html[i] = "</pre></div>"
    end
  end

  local wk_args = { "wkhtmltoimage", "-" }
  if format == "pdf" then
    wk_args = { "wkhtmltopdf", "-" }
  end

  if save_to_file then
    -- Extract just the directory part from save_path & Make sure the directory exists
    local dir_path = vim.fn.fnamemodify(save_path, ":h")
    vim.fn.mkdir(dir_path, "p")

    table.insert(wk_args, save_path)

    local out = vim.system(wk_args, { stdin = html }):wait()
    -- Check if the conversion was successful
    if out.code == 0 then
      local format_show = format == "pdf" and "( pdf)" or "( image)"
      vim.notify("Saved" .. format_show .. ", named: " .. filename .. "." .. format)
    else
      vim.notify("Failed to save image: " .. (out.stderr or "Unknown error"), vim.log.levels.ERROR)
      return nil
    end
  else
    table.insert(wk_args, "-")
    local out = vim.system(wk_args, { stdin = html }):wait()
    vim.system({ "xclip", "-selection", "clipboard", "-t", "image/png" }, { stdin = out.stdout })

    return nil
  end
end

-- MEMO:: function
local visual_convert = function(opts)
  opts = opts or {}
  local save_to_file = opts.save_to_file or false
  local format = opts.format or "png" -- png or pdf
  local timestamp = os.date("%Y%m%d_%H%M%S")
  local root_path = require("utils").get_project_name_by_git() or require("utils").get_project_name_by_cwd()
  local filename = opts.filename or (root_path .. "_" .. timestamp)
  local save_path = opts.save_path or vim.fn.expand("~/Documents/html_to_img") .. "/" .. filename .. "." .. format

  local startLine, endLine = require("utils").get_visual_line()

  local mode = vim.api.nvim_get_mode().mode
  if mode == "n" then
    convert(nil, { save_to_file = save_to_file, format = format, save_path = save_path, filename = filename })
  else
    convert(
      { startLine, endLine },
      { save_to_file = save_to_file, format = format, save_path = save_path, filename = filename }
    )
  end
end

-- MEMO:: keymap
local wk_map = require("utils").wk_map
wk_map({
  ["<leader>d"] = {
    group = "󰷉  Document",
    order = { "c", "s" },
    ["c"] = {
      function()
        visual_convert()
        vim.notify("copied!")
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      end,
      desc = "copy to clipboard (xclip)",
      mode = { "n", "v" },
    },
    ["s"] = {
      function()
        local callback1 = function(format)
          local callback2 = function(filename)
            visual_convert({
              save_to_file = true,
              filename = filename ~= "" and filename or nil,
              format = format,
            })
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
          end
          vim.ui.input({
            prompt = "Name: ",
          }, callback2)
        end
        vim.ui.input({
          prompt = "Format(png/pdf): ",
        }, callback1)
      end,
      desc = "IMG",
      mode = { "n", "v" },
    },
  },
})
