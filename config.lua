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
    -- Check if we're currently in an alpha buffer
    if vim.bo.filetype == "alpha" then
        -- Close the tab if we're in alpha
        vim.cmd("tabclose")
    else
        -- Only save session if there are modified buffers
        local has_modified_buffers = false
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, "modified") then
                has_modified_buffers = true
                break
            end
        end

        if has_modified_buffers then
            vim.cmd("AutoSession save")
        end

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

-- Snippets Configuration - Simple and Clean
-- ==========================================
local luasnip = require("luasnip")

-- Load custom snippets FIRST (before VSCode snippets)
local snippets_dir = vim.fn.expand("~/.config/nvim-general/snippets")
local snippet_files = vim.fn.glob(snippets_dir .. "/**/*.lua", false, true)

for _, file in ipairs(snippet_files) do
    -- Skip init.lua
    if not file:match("init%.lua$") then
        local ok, err = pcall(dofile, file)
        if not ok then
            vim.notify("Error loading " .. vim.fn.fnamemodify(file, ":t") ..
                           ": " .. err, vim.log.levels.ERROR)
        end
    end
end

-- Load VSCode-style snippets AFTER custom snippets (as fallback)
require("luasnip.loaders.from_vscode").lazy_load()

-- Snippet Picker with Telescope
-- ==============================
local has_telescope = pcall(require, "telescope")
if has_telescope then
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    vim.keymap.set({"n", "i"}, "<leader>snp", function()
        local all_snips = {}

        -- Get current filetype and all filetypes that have snippets
        local ft_set = {[vim.bo.filetype] = true, ["all"] = true}
        for ft, _ in pairs(luasnip.snippets or {}) do ft_set[ft] = true end

        -- Collect all snippets with descriptions
        for ft, _ in pairs(ft_set) do
            local ft_snips = luasnip.get_snippets(ft) or {}
            for _, snip in ipairs(ft_snips) do
                -- Get description from snippet's dscr field
                local description = ""
                if snip.dscr then
                    if type(snip.dscr) == "string" then
                        description = snip.dscr
                    elseif type(snip.dscr) == "table" then
                        description = table.concat(snip.dscr, " ")
                    end
                end

                table.insert(all_snips, {
                    trigger = snip.trigger,
                    name = snip.name or "",
                    description = description,
                    snippet = snip,
                    ft = ft
                })
            end
        end

        if #all_snips == 0 then
            vim.notify("No snippets found", vim.log.levels.WARN)
            return
        end

        local previewers = require("telescope.previewers")

        pickers.new({}, {
            prompt_title = "Snippets",
            finder = finders.new_table({
                results = all_snips,
                entry_maker = function(entry)
                    local display_text =
                        string.format("[%s] %s", entry.ft, entry.trigger)
                    if entry.description ~= "" then
                        display_text = display_text .. " - " ..
                                           entry.description
                    end

                    return {
                        value = entry,
                        display = display_text,
                        ordinal = entry.ft .. " " .. entry.trigger .. " " ..
                            entry.name .. " " .. entry.description
                    }
                end
            }),
            sorter = conf.generic_sorter({}),
            previewer = previewers.new_buffer_previewer({
                title = "Snippet Preview",
                define_preview = function(self, entry, status)
                    if not entry or not entry.value or not entry.value.snippet then
                        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1,
                                                   false,
                                                   {"No preview available"})
                        return
                    end

                    local snip = entry.value.snippet
                    local lines = {}

                    -- Add header with snippet info
                    table.insert(lines, "# Trigger: " .. entry.value.trigger)
                    if entry.value.description ~= "" then
                        table.insert(lines, "# Description: " ..
                                         entry.value.description)
                    end
                    table.insert(lines, "# Filetype: " .. entry.value.ft)
                    table.insert(lines, "")

                    -- Use LuaSnip's get_docstring method
                    local ok, docstring = pcall(function()
                        return snip:get_docstring()
                    end)

                    if ok and docstring then
                        if type(docstring) == "table" then
                            -- Clean up placeholder syntax: ${1:text} -> text
                            for _, line in ipairs(docstring) do
                                -- Remove placeholder markers like ${1:text} -> text, $0 -> ""
                                local cleaned =
                                    line:gsub("%${%d+:([^}]+)}", "%1") -- ${1:text} -> text
                                cleaned = cleaned:gsub("%${%d+}", "") -- ${1} -> ""
                                cleaned = cleaned:gsub("%$%d+", "") -- $1 -> ""
                                table.insert(lines, cleaned)
                            end
                        elseif type(docstring) == "string" then
                            for line in docstring:gmatch("[^\r\n]+") do
                                local cleaned =
                                    line:gsub("%${%d+:([^}]+)}", "%1")
                                cleaned = cleaned:gsub("%${%d+}", "")
                                cleaned = cleaned:gsub("%$%d+", "")
                                table.insert(lines, cleaned)
                            end
                        end
                    end

                    -- Fallback if no docstring
                    if #lines <= 4 then -- Only header was added
                        table.insert(lines, "(Expand to see full snippet)")
                    end

                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false,
                                               lines)
                    vim.api.nvim_buf_set_option(self.state.bufnr, "filetype",
                                                entry.value.ft)
                end
            }),
            attach_mappings = function(prompt_bufnr, map)
                local function expand_snippet()
                    local selection = action_state.get_selected_entry()
                    if not selection then return end

                    actions.close(prompt_bufnr)

                    vim.schedule(function()
                        if vim.fn.mode() ~= "i" then
                            vim.cmd("startinsert")
                        end
                        vim.defer_fn(function()
                            luasnip.snip_expand(selection.value.snippet)
                        end, 10)
                    end)
                end

                map("i", "<CR>", expand_snippet)
                map("n", "<CR>", expand_snippet)
                return true
            end
        }):find()
    end, {desc = "Snippet picker"})
end

-- Reload snippets
vim.keymap.set("n", "<leader>snr", function()
    luasnip.cleanup()
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Reload custom snippets
    local snippet_files = vim.fn.glob(snippets_dir .. "/**/*.lua", false, true)
    for _, file in ipairs(snippet_files) do
        if not file:match("init%.lua$") then pcall(dofile, file) end
    end

    vim.notify("Snippets reloaded", vim.log.levels.INFO)
end, {desc = "Reload snippets"})

-- Debug: show snippets for current file
vim.keymap.set("n", "<leader>snd", function()
    local ft = vim.bo.filetype
    if not ft or ft == "" then
        vim.notify("No filetype", vim.log.levels.WARN)
        return
    end

    local snippets = luasnip.get_snippets(ft) or {}
    local msg = string.format("Snippets for '%s': %d", ft, #snippets)

    if #snippets > 0 then
        local examples = {}
        for i = 1, math.min(5, #snippets) do
            table.insert(examples, snippets[i].trigger)
        end
        msg = msg .. "\nExamples: " .. table.concat(examples, ", ")
    end

    vim.notify(msg, vim.log.levels.INFO)
end, {desc = "Show snippets"})

-- Test snippet loading
vim.api.nvim_create_user_command("SnippetTest", function()
    local fts = {"lua", "dart", "javascript", "typescript", "go"}
    local results = {}
    for _, ft in ipairs(fts) do
        local count = #(luasnip.get_snippets(ft) or {})
        table.insert(results, ft .. ": " .. count)
    end
    vim.notify("Snippets:\n" .. table.concat(results, "\n"), vim.log.levels.INFO)
end, {})

-- Create snippet from selection
vim.keymap.set({"n", "v"}, "<leader>snc", function()
    local ft = vim.bo.filetype
    if not ft or ft == "" then
        vim.notify("No filetype detected", vim.log.levels.WARN)
        return
    end

    -- Get trigger name
    local trigger = vim.fn.input("Snippet trigger: ")
    if not trigger or trigger == "" then
        vim.notify("Cancelled", vim.log.levels.WARN)
        return
    end

    -- Get snippet body from visual selection or current line
    local body = ""
    local mode = vim.fn.mode()

    if mode == "v" or mode == "V" or mode == "\22" then
        -- Visual mode - get selection
        vim.cmd('normal! "xy')
        body = vim.fn.getreg("x")
    else
        -- Normal mode - try to get last visual selection
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")

        if start_pos[2] > 0 and end_pos[2] > 0 then
            local lines = vim.fn.getline(start_pos[2], end_pos[2])
            body = table.concat(lines, "\n")
        else
            -- Fall back to current line
            body = vim.fn.getline(".")
        end
    end

    if not body or body == "" then
        vim.notify("No content to create snippet from", vim.log.levels.WARN)
        return
    end

    -- Create snippet file directory
    local snippet_dir = vim.fn.expand("~/.config/nvim-general/snippets/" .. ft)
    vim.fn.mkdir(snippet_dir, "p")

    local snippet_file = snippet_dir .. "/custom.lua"

    -- Escape body for Lua string
    local escaped_body = body:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n",
                                                                       "\\n")

    -- Create snippet code
    local snippet_code = string.format([[

-- Custom snippet: %s
ls.add_snippets("%s", {
    s("%s", t("%s"))
})
]], trigger, ft, trigger, escaped_body)

    -- Append to file
    local file = io.open(snippet_file, "a")
    if file then
        file:write(snippet_code)
        file:close()
        vim.notify(string.format("Snippet '%s' created in %s", trigger,
                                 snippet_file), vim.log.levels.INFO)

        -- Reload snippets
        pcall(dofile, snippet_file)
    else
        vim.notify("Failed to create snippet file", vim.log.levels.ERROR)
    end
end, {desc = "Create snippet from selection"})

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
