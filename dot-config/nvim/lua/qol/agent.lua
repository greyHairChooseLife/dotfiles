-- 외부 에이전트(pi 등)가 이 nvim 세션의 상태를 읽을 수 있게 RPC 소켓을 열고 닫는다.
-- 노출 의도는 아래 state() 하나뿐이다. 버퍼를 수정하는 기능은 넣지 않는다.
local M = {}

local socket_path = nil

local function default_socket_path()
    return vim.fn.stdpath("run") .. "/nvim-agent-" .. vim.fn.getpid() .. ".sock"
end

local function copy_to_clipboard(text)
    -- 클립보드 프로바이더가 없는 환경(headless 등)에서도 실패하지 않게 한다.
    pcall(vim.fn.setreg, "+", text) -- unnamedplus이므로 여기로 충분
    pcall(vim.fn.setreg, "", text) -- 클립보드 프로바이더가 없을 때를 위한 예비
end

--- 해당 경로에 살아있는 서버가 붙어 있는지 확인한다.
---@param path string
---@return boolean
local function is_live(path)
    local ok, chan = pcall(vim.fn.sockconnect, "pipe", path, { rpc = false })
    if ok and type(chan) == "number" and chan > 0 then
        pcall(vim.fn.chanclose, chan)
        return true
    end
    return false
end

--- 이 세션의 현재 상태 스냅샷. 원격에서는 luaeval()로 호출한다.
---@return table
function M.state()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local cursor = vim.api.nvim_win_get_cursor(win)

    local function opts(b)
        return {
            buftype = vim.api.nvim_get_option_value("buftype", { buf = b }),
            filetype = vim.api.nvim_get_option_value("filetype", { buf = b }),
            modified = vim.api.nvim_get_option_value("modified", { buf = b }),
            listed = vim.api.nvim_get_option_value("buflisted", { buf = b }),
        }
    end

    local buffers = {}
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(b) then
            local o = opts(b)
            buffers[#buffers + 1] = {
                buf = b,
                name = vim.api.nvim_buf_get_name(b),
                buftype = o.buftype,
                filetype = o.filetype,
                modified = o.modified,
                listed = o.listed,
            }
        end
    end

    local windows = {}
    for _, w in ipairs(vim.api.nvim_list_wins()) do
        local b = vim.api.nvim_win_get_buf(w)
        local c = vim.api.nvim_win_get_cursor(w)
        windows[#windows + 1] = {
            win = w,
            tab = vim.api.nvim_win_get_tabpage(w),
            buf = b,
            name = vim.api.nvim_buf_get_name(b),
            line = c[1],
            col = c[2],
            current = w == win,
        }
    end

    local o = opts(buf)
    return {
        pid = vim.fn.getpid(),
        socket = socket_path or "",
        cwd = vim.uv.cwd() or "",
        mode = vim.api.nvim_get_mode().mode,
        tab = vim.api.nvim_get_current_tabpage(),
        current = {
            win = win,
            buf = buf,
            name = vim.api.nvim_buf_get_name(buf),
            buftype = o.buftype,
            filetype = o.filetype,
            modified = o.modified,
            line = cursor[1],
            col = cursor[2],
        },
        buffers = buffers,
        windows = windows,
    }
end

function M.share()
    if socket_path then
        copy_to_clipboard(socket_path)
        vim.notify("Already shared. Path copied to clipboard.\n" .. socket_path, vim.log.levels.WARN)
        return
    end

    if vim.env.XDG_RUNTIME_DIR == nil or vim.env.XDG_RUNTIME_DIR == "" then
        vim.notify("XDG_RUNTIME_DIR is not set. Cannot create socket.", vim.log.levels.ERROR)
        return
    end

    local path = default_socket_path()
    if vim.uv.fs_stat(path) then
        if is_live(path) then
            vim.notify("Socket path is in use by another process.\n" .. path, vim.log.levels.ERROR)
            return
        end
        -- 비정상 종료가 남긴 죽은 소켓 파일을 정리한다.
        local unlinked, uerr = vim.uv.fs_unlink(path)
        if not unlinked then
            vim.notify("Cannot remove dead socket file: " .. tostring(uerr), vim.log.levels.ERROR)
            return
        end
    end

    local ok, addr = pcall(vim.fn.serverstart, path)
    if not ok then
        vim.notify("serverstart failed: " .. tostring(addr), vim.log.levels.ERROR)
        return
    end

    socket_path = addr
    copy_to_clipboard(addr)
    vim.notify("Agent socket is listening. Path copied to clipboard.\n" .. addr, vim.log.levels.INFO)
end

function M.unshare()
    if not socket_path then
        vim.notify("Not shared.", vim.log.levels.WARN)
        return
    end

    local ok, err = pcall(vim.fn.serverstop, socket_path)
    if not ok then
        vim.notify("serverstop failed: " .. tostring(err), vim.log.levels.ERROR)
        return
    end

    local closed = socket_path
    socket_path = nil
    vim.notify("Agent socket closed.\n" .. closed, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("AgentShare", M.share, { desc = "이 세션의 에이전트 소켓을 연다. 경로를 클립보드에 복사한다." })
vim.api.nvim_create_user_command("AgentUnshare", M.unshare, { desc = "에이전트 소켓을 닫는다." })

return M
