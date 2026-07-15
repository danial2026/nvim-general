local M = {}

M.config = {
    timeout = 4,
    max_history = 20,
    data_dir = vim.fn.stdpath("data") .. "/url-monitor",
}

M.state = {
    urls = {},
    history = {},
    last_checked = nil,
}

function M.ensure_dir()
    if vim.fn.isdirectory(M.config.data_dir) == 0 then
        vim.fn.mkdir(M.config.data_dir, "p")
    end
end

function M.load()
    M.ensure_dir()
    local url_file = M.config.data_dir .. "/urls.json"
    local hist_file = M.config.data_dir .. "/history.json"

    if vim.fn.filereadable(url_file) == 1 then
        local ok, data = pcall(vim.fn.json_decode,
                               table.concat(vim.fn.readfile(url_file) or {},
                                            "\n"))
        if ok and type(data) == "table" then M.state.urls = data end
    end
    if vim.fn.filereadable(hist_file) == 1 then
        local ok, data = pcall(vim.fn.json_decode,
                               table.concat(vim.fn.readfile(hist_file) or {},
                                            "\n"))
        if ok and type(data) == "table" then M.state.history = data end
    end
end

function M.save()
    M.ensure_dir()
    local f = io.open(M.config.data_dir .. "/urls.json", "w")
    if f then
        f:write(vim.fn.json_encode(M.state.urls))
        f:close()
    end
    local f2 = io.open(M.config.data_dir .. "/history.json", "w")
    if f2 then
        f2:write(vim.fn.json_encode(M.state.history))
        f2:close()
    end
end

function M.add_url()
    vim.ui.input({prompt = "URL: "}, function(url)
        if not url or url == "" then return end
        vim.ui.input({prompt = "Title: "}, function(title)
            if not title or title == "" then title = url end
            vim.ui.input({prompt = "Priority (position, default=end): ",
                          default = tostring(#M.state.urls + 1)}, function(priority)
                local p = tonumber(priority) or (#M.state.urls + 1)
                table.insert(M.state.urls, {
                    title = title,
                    url = url,
                    priority = p,
                })
                table.sort(M.state.urls,
                           function(a, b) return (a.priority or 999) < (b.priority or 999) end)
                M.save()
                vim.schedule(function() M.show() end)
            end)
        end)
    end)
end

function M.remove_url()
    if #M.state.urls == 0 then
        vim.notify("No URLs to remove", vim.log.levels.WARN)
        vim.schedule(function() M.show() end)
        return
    end
    local items = {}
    for i, u in ipairs(M.state.urls) do
        table.insert(items, string.format("%d: [%s] %s", i, u.title, u.url))
    end
    vim.ui.select(items, {prompt = "Select URL to remove:"}, function(_, idx)
        if not idx then
            vim.schedule(function() M.show() end)
            return
        end
        table.remove(M.state.urls, idx)
        M.save()
        vim.schedule(function() M.show() end)
    end)
end

function M.ping_url(url)
    local cmd = string.format(
                    'curl -skL -o /dev/null -w "%%{http_code}:%%{time_total}" --connect-timeout %d -A "Mozilla/5.0" "%s"',
                    M.config.timeout, url)
    local result = vim.fn.system(cmd)
    local exit_code = vim.v.shell_error
    if exit_code ~= 0 or result == "" then
        return false, 0, "DOWN"
    end
    local parts = vim.split(result, ":")
    local http_code = parts[1] or ""
    local latency = tonumber(parts[2]) or 0
    local is_up = http_code ~= ""
    return is_up, latency, http_code
end

function M.ping_all()
    M.state.last_checked = os.date("%H:%M:%S")
    local results = {}
    for i, entry in ipairs(M.state.urls) do
        local is_up, latency, status = M.ping_url(entry.url)
        local url_hist = M.state.history[entry.url] or {}
        table.insert(url_hist, 1, {
            time = os.date("%Y-%m-%d %H:%M:%S"),
            up = is_up,
            latency = latency,
            http = status,
        })
        while #url_hist > M.config.max_history do
            table.remove(url_hist)
        end
        M.state.history[entry.url] = url_hist
        results[i] = {title = entry.title, url = entry.url, up = is_up, latency = latency, http = status}
    end
    M.save()
    return results
end

function M.show()
    M.load()
    local results = M.ping_all()

    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * 0.85)
    local height = math.floor(vim.o.lines * 0.6)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = " URL Monitor ",
        title_pos = "center",
    })
    vim.api.nvim_win_set_option(win, "winhighlight",
                                "Normal:NormalFloat,FloatBorder:FloatBorder")

    local function pad(s, w)
        s = tostring(s)
        if #s >= w then return s end
        return s .. string.rep(" ", w - #s)
    end

    local usable = math.max(20, width - 4)
    local remaining = usable - 27
    local title_col = math.max(1, math.min(20, math.floor(remaining * 0.35)))
    local url_col = math.max(1, remaining - title_col)

    local lines = {}
    local sep = "  " .. string.rep("─", usable)
    table.insert(lines, "  " .. pad("#", 3) .. " " .. pad("Title", title_col) .. " " .. pad("URL", url_col) .. "  Status    Latency")
    table.insert(lines, sep)

    for i, entry in ipairs(M.state.urls) do
        local display_url = entry.url
        if #display_url > url_col then
            display_url = display_url:sub(1, url_col - 3) .. "..."
        end
        local display_title = entry.title
        if #display_title > title_col then
            display_title = display_title:sub(1, title_col - 3) .. "..."
        end

        local status_text = "?"
        local lat_text = ""
        if results and results[i] then
            if results[i].up then
                status_text = "UP"
                lat_text = string.format("%dms", math.floor(results[i].latency * 1000))
            else
                status_text = "DOWN"
                lat_text = "timeout"
            end
        end

        table.insert(lines, "  " .. pad(i .. ".", 3) .. " " .. pad(display_title, title_col) .. " " .. pad(display_url, url_col) .. "  " .. pad(status_text, 6) .. "  " .. lat_text)
    end

    table.insert(lines, "")
    table.insert(lines, "  " .. string.rep("─", usable))
    table.insert(lines, "  [a] Add    [d] Delete    [r] Refresh    [h] History    [q] Close")
    if M.state.last_checked then
        table.insert(lines, "  Last checked: " .. M.state.last_checked)
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
        callback = function() pcall(vim.api.nvim_win_close, win, true) end,
        noremap = true, silent = true, desc = "Close URL monitor"
    })
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
        callback = function() pcall(vim.api.nvim_win_close, win, true) end,
        noremap = true, silent = true, desc = "Close URL monitor"
    })
    vim.api.nvim_buf_set_keymap(buf, "n", "a", "", {
        callback = function()
            pcall(vim.api.nvim_win_close, win, true)
            vim.defer_fn(function() M.add_url() end, 100)
        end,
        noremap = true, silent = true, desc = "Add URL"
    })
    vim.api.nvim_buf_set_keymap(buf, "n", "d", "", {
        callback = function()
            pcall(vim.api.nvim_win_close, win, true)
            vim.defer_fn(function() M.remove_url() end, 100)
        end,
        noremap = true, silent = true, desc = "Remove URL"
    })
    vim.api.nvim_buf_set_keymap(buf, "n", "r", "", {
        callback = function()
            pcall(vim.api.nvim_win_close, win, true)
            vim.defer_fn(function()
                M.load()
                vim.schedule(function() M.show() end)
            end, 100)
        end,
        noremap = true, silent = true, desc = "Refresh pings"
    })
    vim.api.nvim_buf_set_keymap(buf, "n", "h", "", {
        callback = function()
            M.show_history(win)
        end,
        noremap = true, silent = true, desc = "Show ping history"
    })
end

function M.show_history(prev_win)
    pcall(vim.api.nvim_win_close, prev_win, true)

    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * 0.85)
    local height = math.floor(vim.o.lines * 0.6)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = " Ping History ",
        title_pos = "center",
    })
    vim.api.nvim_win_set_option(win, "winhighlight",
                                "Normal:NormalFloat,FloatBorder:FloatBorder")

    local usable = width - 4
    local lines = {}
    for url, entries in pairs(M.state.history) do
        local display_url = url
        if #display_url > usable - 4 then
            display_url = display_url:sub(1, usable - 7) .. "..."
        end
        table.insert(lines, "  URL: " .. display_url)
        table.insert(lines, "  " .. string.rep("─", usable))
        if #entries == 0 then
            table.insert(lines, "  (no pings yet)")
        else
            for _, e in ipairs(entries) do
                local status = e.up and "UP" or "DOWN"
                local lat = e.latency and e.latency > 0 and string.format("%dms", math.floor(e.latency * 1000)) or "-"
                table.insert(lines, string.format("  %s  |  %s  |  %s", e.time, status, lat))
            end
        end
        table.insert(lines, "")
    end

    if vim.tbl_count(M.state.history) == 0 then
        table.insert(lines, "  No ping history yet.")
        table.insert(lines, "")
    end

    table.insert(lines, "  " .. string.rep("─", usable))
    table.insert(lines, "  [b] Back to monitor    [q] Close")

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
        callback = function()
            pcall(vim.api.nvim_win_close, win, true)
        end,
        noremap = true, silent = true, desc = "Close history"
    })
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
        callback = function()
            pcall(vim.api.nvim_win_close, win, true)
        end,
        noremap = true, silent = true, desc = "Close history"
    })
    vim.api.nvim_buf_set_keymap(buf, "n", "b", "", {
        callback = function()
            pcall(vim.api.nvim_win_close, win, true)
            vim.defer_fn(function() M.show() end, 100)
        end,
        noremap = true, silent = true, desc = "Back to monitor"
    })
end

function M.setup()
    M.load()
    vim.keymap.set("n", "<leader>mu", function()
        M.show()
    end, {desc = "Open URL monitor"})
end

return M
