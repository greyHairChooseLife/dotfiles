local M = {}

local function append_to_otp_file(generated)
    local target_file = "/home/sy/Documents/dev-wiki/notes/Area/나를_사랑하기/English_오답노트.md"
    local line_to_append = "[" .. generated .. "](./from_codecompanion_conversation/" .. generated .. ")"

    -- Open the file in append mode
    local file = io.open(target_file, "a")
    if not file then
        vim.notify("Failed to open target file for appending", 4)
        return false
    end

    -- Append the line with a newline before it
    file:write("\n" .. line_to_append)
    file:close()

    -- vim.notify("Successfully appended link to 오답노트.md", vim.log.levels.INFO)
    return true
end

function M.setup()
    vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "CodeCompanionRequestFinished",
        callback = function(_)
            -- Get the messages from the closed chat
            local cdc = require("codecompanion")

            if not cdc.last_chat() or not cdc.last_chat() then
                vim.notify("no messages found", 2, { render = "minimal" })
                return nil
            end

            local messages = cdc.last_chat().messages

            if not messages or #messages == 0 then
                vim.notify("no messages found", 2, { render = "minimal" })
                return nil
            end

            local study_notes = nil
            local last_message = messages[#messages]

            if last_message.role == "llm" and last_message.content and last_message.content:match("# English Study Notes") then
                study_notes = last_message.content
            end

            -- If study notes were found, save them
            if study_notes then
                -- Create directory if it doesn't exist
                local path = "/home/sy/Documents/dev-wiki/notes/Area/나를_사랑하기/from_codecompanion_conversation"
                local notes_dir = vim.fn.expand(path)
                if vim.fn.isdirectory(notes_dir) == 0 then vim.fn.mkdir(notes_dir, "p") end

                -- Generate filename with date and time
                local date_str = os.date("%Y-%m-%d_%H-%M")
                local filename = notes_dir .. "/" .. date_str .. ".md"

                -- Write to file
                local file = io.open(filename, "w")
                if file then
                    file:write(study_notes)
                    file:close()
                    vim.notify("English study notes saved to: " .. filename, 2, { render = "minimal" })
                    append_to_otp_file(date_str)
                else
                    vim.notify("Failed to save English study notes", 4)
                end
            end
        end,
    })
end

return M
