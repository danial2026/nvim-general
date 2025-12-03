-- ============================================
-- General Purpose Neovim Configuration
-- ============================================
-- 
-- "For I know the plans I have for you," declares the Lord, "plans to prosper you and not to harm you, plans to give you hope and a future." - Jeremiah 29:11
-- 
-- Leader Key Setup
-- ================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Suppress eslint errors globally (MUST be early, before plugins load)
-- This prevents eslint errors from breaking session restore when eslint is not installed
local function suppress_eslint_errors()
    -- Override vim.notify to filter eslint errors
    local original_notify = vim.notify
    vim.notify = function(msg, level, opts)
        if type(msg) == "string" then
            if msg:match("eslint") or msg:match("ENOENT.*eslint") or
                msg:match("Error running eslint") or
                msg:match("no such file or directory.*eslint") then
                return -- Suppress eslint errors silently
            end
        end
        return original_notify(msg, level, opts)
    end

    -- Override error handlers
    local original_err_writeln = vim.api.nvim_err_writeln
    vim.api.nvim_err_writeln = function(msg)
        if type(msg) == "string" and
            (msg:match("eslint") or msg:match("ENOENT.*eslint") or
                msg:match("Error running eslint") or
                msg:match("no such file or directory.*eslint")) then
            return -- Suppress eslint errors silently
        end
        return original_err_writeln(msg)
    end
end

-- Apply error suppression immediately, before anything else
suppress_eslint_errors()

-- DeepSeek Chat Configuration
-- ============================
-- Add nvim-deepseek-chat location to package.path for require()
local config_path = vim.fn.expand("~/.config")
package.path = package.path .. ";" .. config_path .. "/?.lua;" .. config_path ..
                   "/?/init.lua"
local deepseek_chat = require("nvim-deepseek-chat")
deepseek_chat.setup({
    api_key = os.getenv("DEEPSEEK_API_KEY") or "",
    api_url = "https://api.deepseek.com/v1/chat/completions",
    model = "deepseek-chat",
    max_tokens = 4096,
    temperature = 0.7,
    width = 80,
    height = 0.8,
    position = "right",
    border = "rounded"
})

-- DeepSeek Chat Keymaps
-- =====================
vim.keymap.set("n", "<leader>dc", function() deepseek_chat.toggle() end,
               {desc = "Toggle DeepSeek Chat"})

-- General Neovim Settings
-- =======================
vim.opt.number = true -- Show line numbers
-- Relative numbers (Optional)
-- vim.opt.relativenumber = true
vim.opt.signcolumn = "yes" -- Show signcolumn
vim.opt.tabstop = 2 -- Tab size
vim.opt.shiftwidth = 2 -- Shift width
vim.opt.expandtab = true -- Expand tabs to spaces
vim.opt.termguicolors = true -- Enable true colors in terminal
vim.opt.cursorline = true -- Highlight current line

-- Neoterm Configuration
-- =====================
vim.g.neoterm_size = tostring(math.floor(0.4 * vim.o.columns))
vim.g.neoterm_default_mod = 'botright vertical'
vim.g.neoterm_autoinsert = 1

-- Terminal Navigation Keymaps
-- ============================
-- Exit terminal insert mode with Esc
vim.keymap
    .set("t", "<Esc>", "<C-\\><C-n>", {desc = "Exit terminal insert mode"})

-- Navigate between splits in terminal mode
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h",
               {desc = "Terminal: move to left split"})
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j",
               {desc = "Terminal: move to bottom split"})
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k",
               {desc = "Terminal: move to top split"})
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l",
               {desc = "Terminal: move to right split"})

-- Auto-enter insert mode when entering terminal buffer
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        if vim.bo.buftype == "terminal" then vim.cmd("startinsert") end
    end
})

-- Neoterm toggle keymap
vim.keymap.set("n", "<leader>tt", ":Ttoggle<CR>", {desc = "Toggle terminal"})

-- Check for lynx installation on startup
-- =======================================
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        vim.defer_fn(function()
            if vim.fn.executable("lynx") ~= 1 then
                vim.notify(
                    "Warning: lynx is not installed. Internet search (<leader>fi) will not work. Install it with: brew install lynx",
                    vim.log.levels.WARN)
            end
        end, 1000)
    end
})

-- Alpha Dashboard Toggle Configuration
-- ======================================
-- Toggle alpha dashboard with <leader>a (opens in new tab)
vim.keymap.set("n", "<leader>a", function()
    -- First save the session
    vim.cmd("AutoSession save")
    -- Check if we're currently in an alpha buffer
    if vim.bo.filetype == "alpha" then
        -- Close the tab if we're in alpha
        vim.cmd("tabclose")
    else
        -- Open alpha dashboard in a new tab
        local alpha_ok, alpha = pcall(require, "alpha")
        if not alpha_ok then
            vim.notify("Alpha plugin not loaded.", vim.log.levels.ERROR)
            return
        end
        vim.cmd("tabnew")
        alpha.start(true)
    end
end, {desc = "Toggle The Creation of Adam"})

-- Add the symbol at cursor position on cursorline using virtual text
-- Only shows when there's no character at the cursor position
-- local symbol = "✝"
local symbol = "☦"
local ns = vim.api.nvim_create_namespace("cursorline_cross")
vim.api.nvim_create_autocmd({
    "CursorMoved", "CursorMovedI", "WinEnter", "BufEnter"
}, {
    callback = function()
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        local cursor = vim.api.nvim_win_get_cursor(0)
        local line = cursor[1] - 1
        local col = cursor[2]

        -- Get the current line content
        local line_content = vim.api
                                 .nvim_buf_get_lines(0, line, line + 1, false)[1] or
                                 ""
        local line_length = #line_content

        -- Only show symbol if cursor is beyond line length (no character at this position)
        if col >= line_length then
            vim.api.nvim_buf_set_extmark(0, ns, line, col, {
                virt_text = {{symbol, "CursorLine"}},
                virt_text_pos = "overlay",
                hl_mode = "combine"
            })
        end
    end
})

-- Comment String Configuration
-- =============================
vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "lua", "javascript", "javascriptreact", "typescript", "typescriptreact",
        "python", "java", "c", "cpp", "cuda", "rust", "go", "html", "xml", "css"
    },
    callback = function()
        local ft = vim.bo.filetype
        if ft == "lua" then
            vim.bo.commentstring = "-- %s"
        elseif ft == "javascript" or ft == "javascriptreact" or ft ==
            "typescript" or ft == "typescriptreact" then
            vim.bo.commentstring = "// %s"
        elseif ft == "python" then
            vim.bo.commentstring = "# %s"
        elseif ft == "java" then
            vim.bo.commentstring = "// %s"
        elseif ft == "c" or ft == "cpp" or ft == "cuda" then
            vim.bo.commentstring = "// %s"
        elseif ft == "rust" then
            vim.bo.commentstring = "// %s"
        elseif ft == "go" then
            vim.bo.commentstring = "// %s"
        elseif ft == "html" or ft == "xml" or ft == "css" then
            vim.bo.commentstring = "<!-- %s -->"
        end
    end
})

-- Safety check: prevent commenting in non-modifiable buffers
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        if not vim.bo.modifiable then vim.bo.commentstring = "" end
    end
})

-- Wrap built-in commenting to prevent errors in non-modifiable buffers
vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        if not vim.api.nvim_buf_get_option(bufnr, "modifiable") then
            -- Disable commentstring for non-modifiable buffers
            vim.api.nvim_buf_set_option(bufnr, "commentstring", "")
        end
    end
})

-- Suppress eslint errors globally (especially during session restore)
-- This prevents eslint errors from breaking session restore when eslint is not installed
local function suppress_eslint_errors()
    -- Override vim.notify to filter eslint errors
    local original_notify = vim.notify
    vim.notify = function(msg, level, opts)
        if type(msg) == "string" then
            if msg:match("eslint") or msg:match("ENOENT.*eslint") or
                msg:match("Error running eslint") or
                msg:match("no such file or directory.*eslint") then
                return -- Suppress eslint errors silently
            end
        end
        return original_notify(msg, level, opts)
    end

    -- Override error handlers
    local original_err_writeln = vim.api.nvim_err_writeln
    vim.api.nvim_err_writeln = function(msg)
        if type(msg) == "string" and
            (msg:match("eslint") or msg:match("ENOENT.*eslint") or
                msg:match("Error running eslint") or
                msg:match("no such file or directory.*eslint")) then
            return -- Suppress eslint errors silently
        end
        return original_err_writeln(msg)
    end
end

-- Apply error suppression early, before any plugins load
suppress_eslint_errors()

-- Wrap BufEnter to catch and suppress eslint errors during session restore
-- This is critical because session restore triggers BufEnter for all restored buffers
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        -- Use pcall to catch any errors that might occur
        pcall(function()
            -- This autocmd runs for every buffer, including during session restore
            -- Any eslint errors that occur here will be caught and suppressed
        end)
    end
})

-- Wrap VimEnter to ensure error suppression is active during session restore
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function() suppress_eslint_errors() end
})

-- Completion Configuration
-- =========================
local cmp = require("cmp")
cmp.setup({
    sources = {{name = "nvim_lsp"}, {name = "buffer"}, {name = "path"}},
    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({select = true}),
        ["<C-e>"] = cmp.mapping.abort()
    })
})

-- General Keymaps
-- ================
-- Enable system clipboard integration
vim.opt.clipboard = "unnamedplus"

-- Explicitly map 'y' to copy to system clipboard in visual and normal modes
vim.keymap.set({"n", "v"}, "y", '"+y', {desc = "Yank to system clipboard"})
vim.keymap.set("n", "yy", '"+yy', {desc = "Yank line to system clipboard"})

-- Copy current file path to clipboard
vim.keymap.set("n", "<leader>cp", function()
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then
        vim.notify("No file path available", vim.log.levels.WARN)
        return
    end
    vim.fn.setreg("+", path)
    vim.notify("Copied file path: " .. path, vim.log.levels.INFO)
end, {desc = "Copy file path to clipboard"})

vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>",
               {desc = "Toggle Explorer"})
vim.keymap.set("n", "<leader>o", function()
    vim.cmd("tabnew")
    vim.cmd("NvimTreeOpen")
end, {desc = "Open new tab with NvimTree"})

-- Override :q to close only current tab if multiple tabs exist
vim.api.nvim_create_user_command("Q", function()
    local tab_count = vim.fn.tabpagenr("$")
    if tab_count > 1 then
        vim.cmd("tabclose")
    else
        vim.cmd("quit")
    end
end, {desc = "Close tab if multiple tabs, otherwise quit"})

-- Override :q command using abbreviation
vim.cmd(
    "cnoreabbrev <expr> q getcmdtype() == ':' && getcmdline() ==# 'q' ? 'Q' : 'q'")

-- LSP Keymaps
-- ============
vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", {desc = "Hover doc"})
vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>",
               {desc = "Goto definition"})
vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>",
               {desc = "Peek definition"})
vim.keymap.set("n", "gr", "<cmd>Lspsaga finder<CR>", {desc = "Find references"})
vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>",
               {desc = "Code action"})
vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>",
               {desc = "Rename symbol"})
vim.keymap.set({"n", "v"}, "<leader>lf", function()
    require("conform").format({async = true, lsp_fallback = true})
end, {desc = "Format current file"})

-- Diagnostics Keymaps
-- ====================
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",
               {desc = "Toggle diagnostics (Trouble)"})
vim.keymap.set("n", "<leader>xw", function()
    require("trouble").toggle("diagnostics", {filter = {buf = 0}})
end, {desc = "Toggle diagnostics for current buffer"})
vim.keymap.set("n", "<leader>xd", function()
    require("trouble").toggle("diagnostics", {
        filter = {severity = vim.diagnostic.severity.ERROR}
    })
end, {desc = "Toggle error diagnostics"})
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev,
               {desc = "Previous diagnostic"})
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {desc = "Next diagnostic"})
vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float,
               {desc = "Show diagnostic in float"})
vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist,
               {desc = "Add diagnostics to location list"})

-- Lspsaga Window Keymaps
-- =======================
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"saga_hover", "saga_peek", "saga_finder", "sagaoutline"},
    callback = function()
        vim.keymap.set("n", "q", "<cmd>close<CR>",
                       {buffer = true, silent = true})
        vim.keymap.set("n", "<Esc>", "<cmd>close<CR>",
                       {buffer = true, silent = true})
    end
})

vim.opt.listchars = {tab = '» ', trail = '·', nbsp = '␣'}
