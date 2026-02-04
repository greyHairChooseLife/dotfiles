local function load_markdown_files(paths)
    local content = ""
    for _, path in ipairs(paths) do
        local file = io.open(path, "r")
        if file then
            content = content .. file:read("*all") .. "\n"
            file:close()
        else
            content = content .. "Error: Could not load " .. path .. "\n"
        end
    end
    return content
end

local markdown_paths = {
    "/home/sy/dotfiles/.claude/skills/excalidraw/SKILL.md",
    "/home/sy/dotfiles/.claude/skills/excalidraw/references/arrows.md",
    "/home/sy/dotfiles/.claude/skills/excalidraw/references/colors.md",
    "/home/sy/dotfiles/.claude/skills/excalidraw/references/examples.md",
    "/home/sy/dotfiles/.claude/skills/excalidraw/references/json-format.md",
    "/home/sy/dotfiles/.claude/skills/excalidraw/references/validation.md",
}

local custom_prefix =
    "Here is the contents that I want to convert into excalidraw format file. A skill description is following with it so take a look and create excalidraw file using @{create_file}\n\n### Contents\n\n`````\n\n`````\n\n\n\n### Skill Description\n\n"

local user_role_content = custom_prefix .. "`````" .. load_markdown_files(markdown_paths) .. "`````"

return {
    strategy = "chat",
    description = "Get full files for references that are related git status.",
    opts = {
        is_default = true, -- don't show on action palette
        is_slash_cmd = true,
        short_name = "create calidraw file",
        auto_submit = true,
        user_prompt = false,
        ignore_system_prompt = true,
        stop_context_insertion = true,
        adapter = {
            name = "copilot",
            model = "gemini-3-pro-preview",
        },
    },
    prompts = {
        {
            role = "user",
            opts = { contains_code = true },
            content = function()
                -- Enable turbo mode!!!
                vim.g.codecompanion_auto_tool_mode = true

                return user_role_content
            end,
        },
    },
}
