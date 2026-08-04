-- Leader Key Setup
-- ================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Completely disable vim.deprecate to suppress all plugin deprecation warnings
-- This is safe because we're using modern, stable plugin versions
vim.deprecate = function() end

-- Also filter vim.notify for any warnings that slip through
local original_notify = vim.notify
vim.notify = function(msg, ...)
    if type(msg) == "string" then
        -- Filter out plugin deprecation warnings during transition period
        if msg:match("deprecated") or msg:match("will be removed") or
            msg:match("checkhealth") or msg:match("dap/") or
            msg:match("js%-debug") or msg:match("Telemetry") then return end
    end
    original_notify(msg, ...)
end

-- Plugin Configuration
-- =====================
-- Make plugins global so it can be accessed from other config files

-- Selected settings (persist theme) helpers (moved to top-level so plugin configs can access them)
local selected_file = vim.fn.expand("~/.config/nvim-general/.selected.json")

local function read_selected()
    local t = {}
    if vim.fn.filereadable(selected_file) == 1 then
        local lines = vim.fn.readfile(selected_file)
        if lines then
            local content = table.concat(lines, "\n")
            local ok, parsed = pcall(vim.fn.json_decode, content)
            if ok and type(parsed) == "table" then t = parsed end
        end
        return t
    end

    -- Fallback: migrate legacy files (.selected_theme)
    local theme_file = vim.fn.expand("~/.config/nvim-general/.selected_theme")
    if vim.fn.filereadable(theme_file) == 1 then
        local lines = vim.fn.readfile(theme_file)
        t.theme = (lines and lines[1]) or t.theme
    end

    if t.theme then
        pcall(function()
            vim.fn.writefile({vim.fn.json_encode(t)}, selected_file)
        end)
    end

    return t
end

local function write_selected(tbl)
    local ok, err = pcall(function()
        return vim.fn.writefile({vim.fn.json_encode(tbl)}, selected_file)
    end)
    return ok, err
end

plugins = {
    -- {"neovim/nvim-lspconfig"}, -- Tree-sitter (Syntax Highlighting)
    -- {
    --     "nvim-treesitter/nvim-treesitter",
    --     build = ":TSUpdate",
    --     config = function()
    --         require("nvim-treesitter.configs").setup({
    --             ensure_installed = {"lua", "vim", "vimdoc"},
    --             highlight = {enable = true},
    --             indent = {enable = true}
    --         })
    --     end
    -- }, -- Completion Engine
    {"hrsh7th/nvim-cmp"}, {"hrsh7th/cmp-nvim-lsp"}, {"hrsh7th/cmp-buffer"},
    {"hrsh7th/cmp-path"}, -- Snippet Engine
    {"L3MON4D3/LuaSnip"}, {"rafamadriz/friendly-snippets"},
    -- File and Text Search, Terminal Management
    {"kassio/neoterm"}, -- UI Components for inputs
    {"MunifTanjim/nui.nvim"}, -- File and Text Search
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        config = function()
            local dart_bin = vim.fn.expand("~/develop/flutter/bin/dart")
            require("conform").setup({
                formatters_by_ft = {
                    dart = { "dart_format" },
                    go = { "gofmt" },
                    lua = { "stylua" },
                    python = { "ruff_format" },
                    json = { "prettier" },
                    jsonc = { "prettier" },
                    yaml = { "prettier" },
                    html = { "prettier" },
                    css = { "prettier" },
                    scss = { "prettier" },
                    javascript = { "prettier" },
                    javascriptreact = { "prettier" },
                    typescript = { "prettier" },
                    typescriptreact = { "prettier" },
                },
                formatters = {
                    dart_format = {
                        command = dart_bin,
                    },
                },
                format_on_save = { lsp_fallback = true, timeout_ms = 800 },
            })
        end
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim", "debugloop/telescope-undo.nvim"
        },
        config = function()
            local telescope = require("telescope")
            local builtin = require("telescope.builtin")
            local actions = require("telescope.actions")

            telescope.setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<Esc>"] = actions.close
                        }
                    },
                    file_ignore_patterns = {
                        "node_modules/", ".git/", "build/", "dist/", ".next/",
                        "coverage/", ".turbo/", ".vercel/", "out/",
                        ".dart_tool/", ".flutter-plugins",
                        ".flutter-plugins-dependencies"
                    }
                },
                extensions = {
                    undo = {
                        use_delta = true,
                        side_by_side = false,
                        layout_strategy = "horizontal",
                        layout_config = {
                            width = 0.95,
                            height = 0.95,
                            preview_width = 0.6,
                            prompt_position = "top"
                        },
                        mappings = {
                            i = {
                                ["<cr>"] = require("telescope-undo.actions").yank_additions,
                                ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
                                ["<C-cr>"] = require("telescope-undo.actions").restore
                            },
                            n = {
                                ["y"] = require("telescope-undo.actions").yank_additions,
                                ["Y"] = require("telescope-undo.actions").yank_deletions,
                                ["u"] = require("telescope-undo.actions").restore
                            }
                        }
                    }
                }
            })

            -- Load telescope extensions
            telescope.load_extension("undo")

            -- Keymaps for searching
            local map = vim.keymap.set

            -- Search in all files in current directory
            map("n", "<leader>ff", builtin.find_files,
                {desc = "Find files in current directory"})
            map("n", "<leader>fa", builtin.live_grep,
                {desc = "Grep text in all files (current directory)"})

            -- Search all keymaps/commands
            map("n", "<leader>fc", builtin.keymaps,
                {desc = "Search all keymaps/commands"})

            -- Search undo history with Telescope
            map("n", "<leader>fu", "<cmd>Telescope undo<CR>",
                {desc = "Search undo history (Telescope)"})

            -- Git Explorer: open script output in a floating terminal at the top
            map("n", "<leader>ge", function()
                local buf = vim.api.nvim_create_buf(false, true) -- [listed=false, scratch=true]
                -- Create floating window config like search results
                local width = math.floor(vim.o.columns * 0.90)
                local height = math.floor(vim.o.lines * 0.45)
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
                    title = " git-explorer (exit with <ctrl> + c)",
                    title_pos = "center"
                })

                -- Optional win highlight for visibility
                vim.api.nvim_win_set_option(win, "winhighlight", "Normal:NormalFloat,FloatBorder:FloatBorder")

                -- Get current user for correct script path
                local handle = io.popen("whoami")
                local user = handle and handle:read("*l") or "root"
                if handle then handle:close() end
                local script_path = "/Users/" .. user .. "/.config/nvim-general/scripts/git-explorer.sh"

                -- Start the git-explorer script in the buffer with a bash shell
                local terminal_job = vim.fn.termopen({"bash", script_path}, {
                    on_exit = function()
                        -- close floating window when the script exits
                        if vim.api.nvim_win_is_valid(win) then
                            vim.api.nvim_win_close(win, true)
                        end
                    end
                })

                -- ONLY q closes, ESC is left alone for the script
                vim.keymap.set("n", "q", function()
                    if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_win_close(win, true)
                    end
                end, { buffer = buf, nowait = true })

                -- stay in terminal mode and stop ESC from leaving it
                vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = buf, noremap = true })

                vim.api.nvim_set_current_win(win)
                vim.cmd("startinsert")
            end, {desc = "Git Explorer (floating top window)"})

            -- Theme picker: browse & preview colorschemes (live preview on move; Enter=apply & persist; Esc/q=restore)
            local pickers = require("telescope.pickers")
            local finders = require("telescope.finders")
            local conf = require("telescope.config").values
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            local previewers = require("telescope.previewers")

            -- Selected settings helpers moved to top-level

            -- discover colorschemes & capture current buffer/theme

            local function theme_picker(opts)
                opts = opts or {}
                -- Compute available colorschemes and capture current colorscheme at runtime
                local themes = vim.fn.getcompletion("", "color") or {}
                table.sort(themes)
                local original_colorscheme = vim.g.colors_name
                local orig_buf = vim.api.nvim_get_current_buf()

                -- Preselect active or persisted theme
                local current_theme = original_colorscheme
                local sel = read_selected()
                if (not current_theme or current_theme == "") and sel and
                    sel.theme then current_theme = sel.theme end
                if current_theme and current_theme ~= "" then
                    opts.default_text = current_theme
                end

                pickers.new(opts, {
                    prompt_title = "Colorschemes (Live preview on move; Enter=Apply & Exit)",
                    finder = finders.new_table({
                        results = themes,
                        entry_maker = function(entry)
                            return {
                                value = entry,
                                display = entry,
                                ordinal = entry
                            }
                        end
                    }),
                    sorter = conf.generic_sorter(opts),
                    previewer = previewers.new_buffer_previewer({
                        define_preview = function(self, entry)
                            -- Use current buffer (or a small sample) for preview
                            local lines = {}
                            if vim.api.nvim_buf_is_valid(orig_buf) then
                                lines = vim.api.nvim_buf_get_lines(orig_buf, 0,
                                                                   -1, false)
                            end
                            if #lines == 0 then
                                lines = {
                                    "-- Theme: " .. entry.value, "",
                                    "function hello(name)",
                                    "  print('Hello, ' .. name)", "end"
                                }
                            end

                            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1,
                                                       false, lines)

                            -- Set preview buffer filetype for correct highlighting
                            local ok, ft = pcall(function()
                                return vim.api.nvim_buf_get_option(orig_buf,
                                                                   "filetype")
                            end)
                            if ok and ft and ft ~= "" then
                                vim.api.nvim_buf_set_option(self.state.bufnr,
                                                            "filetype", ft)
                            else
                                vim.api.nvim_buf_set_option(self.state.bufnr,
                                                            "filetype", "lua")
                            end

                            -- Apply colorscheme for live preview
                            if entry and entry.value then
                                pcall(vim.cmd, "colorscheme " .. entry.value)
                            end
                        end
                    }),
                    attach_mappings = function(prompt_bufnr, map)
                        -- Try to preselect current theme (compatible with multiple Telescope versions)
                        pcall(function()
                            local picker =
                                action_state.get_current_picker(prompt_bufnr)
                            if not picker then return end
                            for i, v in ipairs(themes) do
                                if v == current_theme then
                                    -- Try zero-based index first, then one-based
                                    pcall(function()
                                        picker:set_selection(i - 1)
                                    end)
                                    pcall(function()
                                        picker:set_selection(i)
                                    end)
                                    break
                                end
                            end
                        end)

                        -- Apply selection and persist
                        actions.select_default:replace(function()
                            local selection = action_state.get_selected_entry()
                            actions.close(prompt_bufnr)
                            if selection and selection.value then
                                local ok, err =
                                    pcall(vim.cmd,
                                          "colorscheme " .. selection.value)
                                if ok then
                                    vim.notify(
                                        "Applied theme: " .. selection.value,
                                        vim.log.levels.INFO)
                                    -- Persist the selected theme into combined settings file
                                    local s = read_selected()
                                    s.theme = selection.value
                                    local write_ok, write_err =
                                        write_selected(s)
                                    if write_ok then
                                        vim.notify(
                                            "Saved theme to: " .. selected_file,
                                            vim.log.levels.INFO)
                                    else
                                        vim.notify(
                                            "Failed to save theme: " ..
                                                tostring(write_err),
                                            vim.log.levels.ERROR)
                                    end
                                else
                                    vim.notify(
                                        "Failed to apply theme: " ..
                                            tostring(err), vim.log.levels.ERROR)
                                end
                            end
                        end)

                        -- Esc/q: cancel and restore original theme
                        map("i", "<Esc>", function()
                            actions.close(prompt_bufnr)
                            if original_colorscheme then
                                pcall(vim.cmd,
                                      "colorscheme " .. original_colorscheme)
                            end
                        end)
                        map("n", "q", function()
                            actions.close(prompt_bufnr)
                            if original_colorscheme then
                                pcall(vim.cmd,
                                      "colorscheme " .. original_colorscheme)
                            end
                        end)

                        return true
                    end
                }):find()
            end

            -- Command + keymap to open theme picker with a right-side preview
            vim.api.nvim_create_user_command("ThemePicker", function()
                theme_picker({
                    layout_strategy = "horizontal",
                    layout_config = {
                        width = 0.9,
                        height = 0.9,
                        preview_width = 0.6
                    },
                    prompt_position = "top"
                })
            end, {})

            vim.keymap.set("n", "<leader>th", "<cmd>ThemePicker<CR>", {
                desc = "Theme picker (live preview; Enter=apply, Esc=cancel)"
            })

            -- Grep content NOT in .gitignore (respects .gitignore patterns)
            map("n", "<leader>fg", function()
                local builtin = require("telescope.builtin")
                local previewers = require("telescope.previewers")
                local conf = require("telescope.config").values

                -- Custom previewer using bat for grep results
                local bat_previewer = previewers.new_termopen_previewer({
                    get_command = function(entry)
                        local filename = entry.filename or entry.path or entry.value or ""
                        local lnum = tonumber(entry.lnum or entry.line or (entry.value and entry.value:match(":(%d+):"))) or 1
                        if not filename or filename == "" then
                            return { "echo", "" }
                        end
                        -- Center the preview around the highlighted line (bat supports --line-range)
                        local context = 20 -- lines before and after; adjust as desired for preview height
                        local start_line = math.max(lnum - context, 1)
                        local end_line = lnum + context
                        local args = {
                            "--style=numbers,changes",
                            "--theme=OneHalfDark",
                            "-l", "conf",
                            "--color=always",
                            "--highlight-line", tostring(lnum),
                            "--line-range", string.format("%d:%d", start_line, end_line),
                            filename
                        }
                        return vim.tbl_flatten({ "bat", args })
                    end
                })

                builtin.live_grep({
                    prompt_title = "Grep (respecting .gitignore)",
                    previewer = bat_previewer,
                    use_regex = true,
                })
            end, { desc = "Grep content (respect .gitignore)" })


            -- Search in specific subdirectory
            map("n", "<leader>fs", function()
                local search_dir = vim.fn.input(
                                       "Search in directory (e.g., lib/api/): ")
                if search_dir ~= "" then
                    -- Ensure directory path ends with / if it doesn't already
                    if search_dir:sub(-1) ~= "/" then
                        search_dir = search_dir .. "/"
                    end
                    builtin.live_grep({
                        search_dirs = {search_dir},
                        prompt_title = "Search in: " .. search_dir
                    })
                end
            end, {desc = "Grep text in specific subdirectory"})

            -- Search files in specific subdirectory
            map("n", "<leader>fd", function()
                local search_dir = vim.fn.input(
                                       "Find files in directory (e.g., lib/api/): ")
                if search_dir ~= "" then
                    -- Ensure directory path ends with / if it doesn't already
                    if search_dir:sub(-1) ~= "/" then
                        search_dir = search_dir .. "/"
                    end
                    builtin.find_files({
                        search_dirs = {search_dir},
                        prompt_title = "Files in: " .. search_dir
                    })
                end
            end, {desc = "Find files in specific subdirectory"})

            -- Internet search using lynx (opens in terminal split)
            map("n", "<leader>fi", function()
                -- Check if lynx is installed
                local lynx_installed = vim.fn.executable("lynx") == 1
                if not lynx_installed then
                    vim.notify(
                        "lynx is not installed. Install it with: brew install lynx",
                        vim.log.levels.ERROR)
                    return
                end

                local Popup = require("nui.popup")
                local event = require("nui.utils.autocmd").event

                local popup = Popup({
                    position = "50%",
                    size = {width = 60, height = 6},
                    border = {
                        style = "single",
                        text = {
                            top = " Search StackOverflow ",
                            top_align = "center"
                        }
                    },
                    win_options = {
                        winhighlight = "Normal:Normal,FloatBorder:Normal"
                    }
                })

                local search_text = ""
                local token_text = ""
                local current_field = 1

                local function render()
                    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, {
                        "Search: " .. search_text ..
                            (current_field == 1 and "_" or ""), "",
                        "Bearer Token (optional): " .. token_text ..
                            (current_field == 2 and "_" or ""), "",
                        "Press Tab to switch fields, Enter to submit, Esc to cancel"
                    })
                end

                local function execute_search()
                    if search_text ~= "" then
                        popup:unmount()

                        -- URL encode the search text
                        local encoded_text = search_text:gsub(" ", "+")

                        -- Use DuckDuckGo
                        local url = string.format(
                                        "https://duckduckgo.com/html/?q=%s+site:stackoverflow.com",
                                        encoded_text)

                        -- Run lynx in terminal split
                        local escaped_url = url:gsub('"', '\\"')
                        local headers = 'User-Agent: Mozilla/5.0'

                        -- Add Authorization header if token provided
                        if token_text ~= "" then
                            local escaped_token = token_text:gsub('"', '\\"')
                            headers = headers ..
                                          '\\" -head=\\"Authorization: Bearer ' ..
                                          escaped_token
                        end

                        local cmd = string.format(
                                        'bash -c "lynx -accept_all_cookies -head=\\"%s\\" \\"%s\\"" && exit',
                                        headers, escaped_url)

                        vim.cmd("T " .. cmd)
                    end
                end

                popup:mount()
                render()

                -- Set cursor position and focus on the popup window
                vim.api.nvim_set_current_win(popup.winid)
                vim.api.nvim_win_set_cursor(popup.winid, {1, 8})

                -- Key mappings
                popup:map("n", "<Esc>", function()
                    popup:unmount()
                end, {noremap = true})

                popup:map("n", "<Tab>", function()
                    current_field = current_field == 1 and 2 or 1
                    render()
                end, {noremap = true})

                popup:map("n", "<CR>", function()
                    execute_search()
                end, {noremap = true})

                popup:map("i", "<Tab>", function()
                    current_field = current_field == 1 and 2 or 1
                    render()
                end, {noremap = true})

                popup:map("i", "<CR>", function()
                    execute_search()
                end, {noremap = true})

                popup:map("i", "<BS>", function()
                    if current_field == 1 and #search_text > 0 then
                        search_text = search_text:sub(1, -2)
                    elseif current_field == 2 and #token_text > 0 then
                        token_text = token_text:sub(1, -2)
                    end
                    vim.schedule(render)
                end, {noremap = true})

                -- Handle character input
                vim.api.nvim_create_autocmd("InsertCharPre", {
                    buffer = popup.bufnr,
                    callback = function()
                        local char = vim.v.char
                        if current_field == 1 then
                            search_text = search_text .. char
                        elseif current_field == 2 then
                            token_text = token_text .. char
                        end
                        vim.schedule(render)
                        vim.v.char = ""
                    end
                })

                popup:on(event.BufLeave, function()
                    popup:unmount()
                end)

                -- Enter insert mode
                vim.schedule(function() vim.cmd("startinsert") end)
            end, {desc = "Search internet (StackOverflow via lynx)"})

            -- Open any URL in lynx (opens in terminal split)
            map("n", "<leader>fo", function()
                -- Check if lynx is installed
                local lynx_installed = vim.fn.executable("lynx") == 1
                if not lynx_installed then
                    vim.notify(
                        "lynx is not installed. Install it with: brew install lynx",
                        vim.log.levels.ERROR)
                    return
                end

                local Popup = require("nui.popup")
                local event = require("nui.utils.autocmd").event

                -- Cache file path
                local cache_file = vim.fn.stdpath("data") ..
                                       "/lynx_url_cache.json"

                -- Load cached values
                local function load_cache()
                    local file = io.open(cache_file, "r")
                    if file then
                        local content = file:read("*a")
                        file:close()
                        local success, data = pcall(vim.json.decode, content)
                        if success and data then
                            return data.url or "", data.token or ""
                        end
                    end
                    return "", ""
                end

                -- Save cache
                local function save_cache(url, token)
                    local data = vim.json.encode({url = url, token = token})
                    local file = io.open(cache_file, "w")
                    if file then
                        file:write(data)
                        file:close()
                    end
                end

                local popup = Popup({
                    position = "50%",
                    size = {width = 60, height = 6},
                    border = {
                        style = "single",
                        text = {top = " Open URL ", top_align = "center"}
                    },
                    win_options = {
                        winhighlight = "Normal:Normal,FloatBorder:Normal"
                    }
                })

                local url_text, token_text = load_cache()
                local current_field = 1

                local function render()
                    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, {
                        "URL: " .. url_text ..
                            (current_field == 1 and "_" or ""), "",
                        "Bearer Token (optional): " .. token_text ..
                            (current_field == 2 and "_" or ""), "",
                        "Press Tab to switch fields, Enter to submit, Esc to cancel"
                    })
                end

                local function execute_request()
                    if url_text ~= "" then
                        -- Save cache
                        save_cache(url_text, token_text)

                        popup:unmount()

                        -- Run lynx in terminal split
                        local escaped_url = url_text:gsub('"', '\\"')
                        local headers = 'User-Agent: Mozilla/5.0'

                        -- Add Authorization header if token provided
                        if token_text ~= "" then
                            local escaped_token = token_text:gsub('"', '\\"')
                            headers = headers ..
                                          '\\" -head=\\"Authorization: Bearer ' ..
                                          escaped_token
                        end

                        local cmd = string.format(
                                        'bash -c "lynx -accept_all_cookies -head=\\"%s\\" \\"%s\\"" && exit',
                                        headers, escaped_url)

                        vim.cmd("T " .. cmd)
                    end
                end

                popup:mount()
                render()

                -- Set cursor position and focus on the popup window
                vim.api.nvim_set_current_win(popup.winid)
                vim.api.nvim_win_set_cursor(popup.winid, {1, 5})

                -- Key mappings
                popup:map("n", "<Esc>", function()
                    popup:unmount()
                end, {noremap = true})

                popup:map("n", "<Tab>", function()
                    current_field = current_field == 1 and 2 or 1
                    render()
                end, {noremap = true})

                popup:map("n", "<CR>", function()
                    execute_request()
                end, {noremap = true})

                popup:map("i", "<Tab>", function()
                    current_field = current_field == 1 and 2 or 1
                    render()
                end, {noremap = true})

                popup:map("i", "<CR>", function()
                    execute_request()
                end, {noremap = true})

                popup:map("i", "<BS>", function()
                    if current_field == 1 and #url_text > 0 then
                        url_text = url_text:sub(1, -2)
                    elseif current_field == 2 and #token_text > 0 then
                        token_text = token_text:sub(1, -2)
                    end
                    vim.schedule(render)
                end, {noremap = true})

                -- Handle character input
                vim.api.nvim_create_autocmd("InsertCharPre", {
                    buffer = popup.bufnr,
                    callback = function()
                        local char = vim.v.char
                        if current_field == 1 then
                            url_text = url_text .. char
                        elseif current_field == 2 then
                            token_text = token_text .. char
                        end
                        vim.schedule(render)
                        vim.v.char = ""
                    end
                })

                popup:on(event.BufLeave, function()
                    popup:unmount()
                end)

                -- Enter insert mode
                vim.schedule(function() vim.cmd("startinsert") end)
            end, {desc = "Open URL in lynx"})
        end
    }, -- Commenting
    {
        "numToStr/Comment.nvim",
        config = function()
            local comment = require("Comment")
            comment.setup({
                padding = true,
                sticky = true,
                ignore = "^$",
                mappings = {basic = false, extra = false, extended = false},
                pre_hook = function(ctx)
                    -- Set commentstring based on filetype
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

            -- Custom mappings with gC prefix
            local api = require("Comment.api")
            local map = vim.keymap.set

            -- Explicitly remove any default mappings that might conflict
            pcall(vim.keymap.del, "n", "gcc")
            pcall(vim.keymap.del, "n", "gbc")
            pcall(vim.keymap.del, "n", "gc")
            pcall(vim.keymap.del, "n", "gb")
            pcall(vim.keymap.del, "v", "gc")
            pcall(vim.keymap.del, "v", "gb")

            -- Line comment: gCc (instead of gcc)
            map("n", "gCc", function()
                if vim.bo.modifiable then
                    api.toggle.linewise.current()
                else
                    vim.notify("Buffer is not modifiable", vim.log.levels.WARN)
                end
            end, {desc = "Comment line"})

            -- Block comment: gCb (instead of gbc)
            map("n", "gCb", function()
                if vim.bo.modifiable then
                    api.toggle.blockwise.current()
                else
                    vim.notify("Buffer is not modifiable", vim.log.levels.WARN)
                end
            end, {desc = "Comment block"})

            -- Operator/Visual mode: gc (for motions like gCiw, gCap, or visual selections)
            map({"n", "v"}, "gc",
                api.locked(function() return api.toggle.linewise end),
                {desc = "Comment operator/selection"})

            -- Block operator/Visual mode: gB (capital B to avoid conflicts)
            map({"n", "v"}, "gB",
                api.locked(function() return api.toggle.blockwise end),
                {desc = "Comment block operator/selection"})
        end
    }, -- UI Components
    {"nvim-lualine/lualine.nvim", config = true}, -- Git Integration
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = {text = "│"},
                    change = {text = "│"},
                    delete = {text = "_"},
                    topdelete = {text = "‾"},
                    changedelete = {text = "~"},
                    untracked = {text = "┆"}
                },
                signcolumn = true,
                numhl = true,
                linehl = false,
                word_diff = true,
                watch_gitdir = {interval = 1000, follow_files = true},
                attach_to_untracked = true,
                current_line_blame = true,
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = "eol",
                    delay = 500,
                    ignore_whitespace = false
                },
                current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
                sign_priority = 6,
                update_debounce = 100,
                status_formatter = nil,
                max_file_length = 40000,
                preview_config = {
                    border = "rounded",
                    style = "minimal",
                    relative = "cursor",
                    row = 0,
                    col = 1
                },
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map("n", "]c", function()
                        if vim.wo.diff then return "]c" end
                        vim.schedule(function()
                            gs.next_hunk()
                        end)
                        return "<Ignore>"
                    end, {expr = true, desc = "Next git hunk"})

                    map("n", "[c", function()
                        if vim.wo.diff then return "[c" end
                        vim.schedule(function()
                            gs.prev_hunk()
                        end)
                        return "<Ignore>"
                    end, {expr = true, desc = "Previous git hunk"})

                    -- Actions
                    map("n", "<leader>hs", gs.stage_hunk, {desc = "Stage hunk"})
                    map("n", "<leader>hr", gs.reset_hunk, {desc = "Reset hunk"})
                    local function visual_range()
                        return {
                            math.min(vim.fn.line("."), vim.fn.line("v")),
                            math.max(vim.fn.line("."), vim.fn.line("v"))
                        }
                    end

                    local function save_backup_and_revert(range)
                        local file = vim.fn.expand("%:p")
                        local lines = vim.fn.getline(range[1], range[2])
                        vim.g.gitsigns_undo_backup = {
                            file = file,
                            start = range[1],
                            ["end"] = range[2],
                            lines = lines,
                            timestamp = os.time()
                        }
                        gs.reset_hunk(range)
                        vim.notify(string.format(
                            "Reverted lines %d-%d. 'u' to undo, '<leader>hU' to redo.",
                            range[1], range[2]))
                    end

                    map("v", "<leader>hs", function()
                        gs.stage_hunk(visual_range())
                    end, {desc = "Stage selected hunk"})
                    map("v", "<leader>hr", function()
                        save_backup_and_revert(visual_range())
                    end, {desc = "Revert selected lines"})
                    map("v", "<leader>hu", function()
                        save_backup_and_revert(visual_range())
                    end, {desc = "Revert selected lines (with redo backup)"})
                    map("n", "<leader>hS", gs.stage_buffer,
                        {desc = "Stage buffer"})
                    map("n", "<leader>hu", gs.undo_stage_hunk,
                        {desc = "Undo stage hunk"})
                    map("n", "<leader>hU", function()
                        local b = vim.g.gitsigns_undo_backup
                        if not b or not b.file then
                            vim.notify("No backup to restore", vim.log.levels.WARN)
                            return
                        end
                        local file = vim.fn.expand("%:p")
                        if b.file ~= file then
                            vim.notify("File mismatch. Backup is for: " .. b.file,
                                vim.log.levels.WARN)
                            return
                        end
                        vim.api.nvim_buf_set_lines(0, b.start - 1, b["end"], false, b.lines)
                        vim.notify(string.format(
                            "Restored lines %d-%d. 'u' to revert again.",
                            b.start, b["end"]))
                    end, {desc = "Redo: restore last reverted selection"})
                    map("n", "<leader>hR", gs.reset_buffer,
                        {desc = "Reset buffer"})
                    map("n", "<leader>hp", gs.preview_hunk,
                        {desc = "Preview hunk"})
                    map("n", "<leader>hb",
                        function()
                        gs.blame_line({full = true})
                    end, {desc = "Blame line"})
                    map("n", "<leader>tb", gs.toggle_current_line_blame,
                        {desc = "Toggle line blame"})
                    map("n", "<leader>hd", gs.diffthis, {desc = "Diff this"})
                    map("n", "<leader>hD", function()
                        gs.diffthis("~")
                    end, {desc = "Diff this ~"})
                    map("n", "<leader>td", gs.toggle_deleted,
                        {desc = "Toggle deleted"})

                    -- Text object
                    map({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>",
                        {desc = "Select hunk"})
                end
            })
        end
    }, {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim", "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim"
        },
        config = function()
            local neogit = require("neogit")
            neogit.setup({
                kind = "tab",
                commit_editor = {kind = "tab"},
                commit_select_view = {kind = "tab"},
                commit_view = {kind = "vsplit"},
                log_view = {kind = "tab"},
                rebase_editor = {kind = "auto"},
                reflog_view = {kind = "tab"},
                merge_editor = {kind = "auto"},
                tag_editor = {kind = "auto"},
                preview_buffer = {kind = "split"},
                popup = {kind = "split"},
                signs = {
                    hunk = {"", ""},
                    item = {"▸", "▾"},
                    section = {"▸", "▾"}
                },
                integrations = {diffview = true, telescope = true},
                sections = {
                    untracked = {folded = false, hidden = false},
                    unstaged = {folded = false, hidden = false},
                    staged = {folded = false, hidden = false},
                    stashes = {folded = true, hidden = false},
                    unpulled_upstream = {folded = true, hidden = false},
                    unmerged_upstream = {folded = false, hidden = false},
                    unpulled_pushRemote = {folded = true, hidden = false},
                    unmerged_pushRemote = {folded = false, hidden = false},
                    recent = {folded = true, hidden = false}
                },
                mappings = {
                    finder = {
                        ["<CR>"] = "Select",
                        ["<C-c>"] = "Close",
                        ["<Esc>"] = "Close",
                        ["<C-n>"] = "Next",
                        ["<C-p>"] = "Previous",
                        ["<Down>"] = "Next",
                        ["<Up>"] = "Previous",
                        ["<Tab>"] = "MultiselectToggleNext",
                        ["<S-Tab>"] = "MultiselectTogglePrevious",
                        ["<C-j>"] = "NOP"
                    },
                    popup = {
                        ["?"] = "HelpPopup",
                        ["A"] = "CherryPickPopup",
                        ["D"] = "DiffPopup",
                        ["M"] = "RemotePopup",
                        ["P"] = "PushPopup",
                        ["X"] = "ResetPopup",
                        ["Z"] = "StashPopup",
                        ["b"] = "BranchPopup",
                        ["c"] = "CommitPopup",
                        ["f"] = "FetchPopup",
                        ["l"] = "LogPopup",
                        ["m"] = "MergePopup",
                        ["p"] = "PullPopup",
                        ["r"] = "RebasePopup",
                        ["v"] = "RevertPopup"
                    },
                    status = {
                        ["q"] = "Close",
                        ["I"] = "InitRepo",
                        ["1"] = "Depth1",
                        ["2"] = "Depth2",
                        ["3"] = "Depth3",
                        ["4"] = "Depth4",
                        ["<Tab>"] = "Toggle",
                        ["x"] = "Discard",
                        ["s"] = "Stage",
                        ["S"] = "StageUnstaged",
                        ["<C-s>"] = "StageAll",
                        ["u"] = "Unstage",
                        ["U"] = "UnstageStaged",
                        ["$"] = "CommandHistory",
                        ["Y"] = "YankSelected",
                        ["<C-r>"] = "RefreshBuffer",
                        ["<CR>"] = "GoToFile",
                        ["<C-v>"] = "VSplitOpen",
                        ["<C-x>"] = "SplitOpen",
                        ["<C-t>"] = "TabOpen",
                        ["{"] = "GoToPreviousHunkHeader",
                        ["}"] = "GoToNextHunkHeader",
                        ["[c"] = "OpenOrScrollUp",
                        ["]c"] = "OpenOrScrollDown"
                    }
                }
            })

            -- Keymaps
            local map = vim.keymap.set
            map("n", "<leader>gg", "<cmd>Neogit<CR>", {desc = "Open Neogit"})

            -- Git add commands
            map("n", "<leader>ga", function()
                local file = vim.fn.expand("%")
                if file ~= "" then
                    vim.fn.system({"git", "add", file})
                    vim.notify("Staged: " .. file, vim.log.levels.INFO)
                    -- Refresh gitsigns
                    vim.cmd("edit")
                else
                    vim.notify("No file to stage", vim.log.levels.WARN)
                end
            end, {desc = "Git add (current file)"})

            map("n", "<leader>gA", function()
                vim.fn.system({"git", "add", "."})
                vim.notify("Staged all files", vim.log.levels.INFO)
                -- Refresh gitsigns
                vim.cmd("edit")
            end, {desc = "Git add . (all files)"})

            -- Interactive file picker for staging
            map("n", "<leader>gs", function()
                local pickers = require("telescope.pickers")
                local finders = require("telescope.finders")
                local conf = require("telescope.config").values
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")
                local previewers = require("telescope.previewers")

                -- Get unstaged files
                local unstaged = vim.fn.systemlist("git diff --name-only")
                local untracked = vim.fn.systemlist(
                                      "git ls-files --others --exclude-standard")
                local all_files = vim.list_extend(unstaged, untracked)

                if #all_files == 0 then
                    vim.notify("No unstaged files", vim.log.levels.INFO)
                    return
                end

                pickers.new({}, {
                    prompt_title = "Stage Files (Tab=select, Enter=stage)",
                    finder = finders.new_table({
                        results = all_files,
                        entry_maker = function(entry)
                            return {
                                value = entry,
                                display = entry,
                                ordinal = entry,
                                path = entry
                            }
                        end
                    }),
                    sorter = conf.generic_sorter({}),
                    previewer = previewers.new_termopen_previewer({
                        get_command = function(entry)
                            -- Show diff for the file
                            return {
                                "git", "diff", "HEAD", "--color=always", "--",
                                entry.value
                            }
                        end
                    }),
                    attach_mappings = function(prompt_bufnr, map)
                        actions.select_default:replace(function()
                            local picker =
                                action_state.get_current_picker(prompt_bufnr)
                            local selections = picker:get_multi_selection()
                            actions.close(prompt_bufnr)

                            -- If no multi-selection, stage the current entry
                            if #selections == 0 then
                                local selection =
                                    action_state.get_selected_entry()
                                if selection then
                                    vim.fn.system({
                                        "git", "add", selection.value
                                    })
                                    vim.notify("Staged: " .. selection.value,
                                               vim.log.levels.INFO)
                                end
                            else
                                -- Stage all selected files
                                for _, selection in ipairs(selections) do
                                    vim.fn.system({
                                        "git", "add", selection.value
                                    })
                                end
                                vim.notify("Staged " .. #selections .. " files",
                                           vim.log.levels.INFO)
                            end
                            vim.cmd("checktime")
                        end)
                        return true
                    end
                }):find()
            end, {desc = "Git stage (pick files)"})

            -- Interactive file picker for unstaging
            map("n", "<leader>gu", function()
                local pickers = require("telescope.pickers")
                local finders = require("telescope.finders")
                local conf = require("telescope.config").values
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")
                local previewers = require("telescope.previewers")

                -- Get staged files
                local staged = vim.fn
                                   .systemlist("git diff --cached --name-only")

                if #staged == 0 then
                    vim.notify("No staged files", vim.log.levels.INFO)
                    return
                end

                pickers.new({}, {
                    prompt_title = "Unstage Files (Tab=select, Enter=unstage)",
                    finder = finders.new_table({
                        results = staged,
                        entry_maker = function(entry)
                            return {
                                value = entry,
                                display = entry,
                                ordinal = entry,
                                path = entry
                            }
                        end
                    }),
                    sorter = conf.generic_sorter({}),
                    previewer = previewers.new_termopen_previewer({
                        get_command = function(entry)
                            -- Show staged diff for the file
                            return {
                                "git", "diff", "--cached", "--color=always",
                                "--", entry.value
                            }
                        end
                    }),
                    attach_mappings = function(prompt_bufnr, map)
                        actions.select_default:replace(function()
                            local picker =
                                action_state.get_current_picker(prompt_bufnr)
                            local selections = picker:get_multi_selection()
                            actions.close(prompt_bufnr)

                            -- If no multi-selection, unstage the current entry
                            if #selections == 0 then
                                local selection =
                                    action_state.get_selected_entry()
                                if selection then
                                    vim.fn.system({
                                        "git", "reset", "HEAD", selection.value
                                    })
                                    vim.notify("Unstaged: " .. selection.value,
                                               vim.log.levels.INFO)
                                end
                            else
                                -- Unstage all selected files
                                for _, selection in ipairs(selections) do
                                    vim.fn.system({
                                        "git", "reset", "HEAD", selection.value
                                    })
                                end
                                vim.notify(
                                    "Unstaged " .. #selections .. " files",
                                    vim.log.levels.INFO)
                            end
                            vim.cmd("checktime")
                        end)
                        return true
                    end
                }):find()
            end, {desc = "Git unstage (pick files)"})

            -- Git log graph command
            map("n", "<leader>gL", function()
                -- Open in a new tab with a proper terminal buffer
                vim.cmd("tabnew")
                local bufnr = vim.api.nvim_get_current_buf()

                -- Set terminal scrollback
                vim.o.scrollback = 100000

                -- Open terminal with git log
                local job_id = vim.fn.termopen(
                                   "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit",
                                   {
                        on_exit = function()
                            -- Stay in the buffer after git finishes
                        end
                    })

                -- Switch to normal mode after a short delay
                vim.defer_fn(function()
                    -- Send Ctrl-C to ensure we're not waiting for input
                    vim.api.nvim_chan_send(job_id, "\x03")
                    -- Switch to normal mode
                    vim.cmd("stopinsert")

                    -- Set up keybindings in normal mode
                    vim.keymap.set("n", "q", "<cmd>q!<CR>",
                                   {buffer = bufnr, silent = true})
                    vim.keymap.set("n", "<Esc>", "<cmd>q!<CR>",
                                   {buffer = bufnr, silent = true})
                end, 500)
            end, {desc = "Git log graph (pretty)"})
        end
    }, {
        "sindrets/diffview.nvim",
        dependencies = {"nvim-lua/plenary.nvim"},
        config = function()
            local actions = require("diffview.actions")

            local function git_root()
                local r = vim.fn.systemlist(
                              {"git", "rev-parse", "--show-toplevel"})
                return #r > 0 and r[1] or nil
            end

            local function file_at_cursor()
                local ok, view = pcall(require("diffview.lib").get_current_view)
                if not ok or not view then return nil end
                local ok2, entry = pcall(view.get_current_entry, view)
                if not ok2 or not entry then return nil end
                return entry.path
            end

            local function run_git(git_args)
                local root = git_root()
                if not root then return end
                vim.fn.system(vim.list_extend(
                                  {"git", "-C", root}, git_args))
            end

            require("diffview").setup({
                diff_binaries = false,
                enhanced_diff_hl = true,
                git_cmd = {"git"},
                use_icons = true,
                show_help_hints = true,
                watch_index = true,
                icons = {folder_closed = "", folder_open = ""},
                signs = {fold_closed = "▸", fold_open = "▾", done = "✓"},
                view = {
                    default = {layout = "diff2_horizontal"},
                    merge_tool = {layout = "diff3_horizontal"},
                    file_history = {layout = "diff2_horizontal"}
                },
                file_panel = {
                    listing_style = "tree",
                    tree_options = {
                        flatten_dirs = true,
                        folder_statuses = "only_folded"
                    },
                    win_config = {position = "left", width = 35}
                },
                file_history_panel = {
                    log_options = {
                        git = {
                            single_file = {
                                diff_merges = "combined",
                                follow = true
                            },
                            multi_file = {diff_merges = "first-parent"}
                        }
                    },
                    win_config = {position = "bottom", height = 16}
                },
                commit_log_panel = {win_config = {height = 16}},
                default_args = {DiffviewOpen = {}, DiffviewFileHistory = {}},
                hooks = {},
                keymaps = {
                    disable_defaults = false,
                    view = {
                        ["<Tab>"] = actions.select_next_entry,
                        ["<S-Tab>"] = actions.select_prev_entry,
                        ["<C-w><C-f>"] = actions.goto_file_split,
                        ["<C-w>gf"] = actions.goto_file_tab,
                        ["<leader>e"] = actions.focus_files,
                        ["<leader>b"] = actions.toggle_files,
                        ["g<C-x>"] = actions.cycle_layout,
                        ["[x"] = actions.prev_conflict,
                        ["]x"] = actions.next_conflict,
                        ["<Esc>"] = actions.close,
                        ["q"] = actions.close,

                        ["gd"] = function()
                            local file = file_at_cursor()
                            if not file then return end
                            local root = git_root()
                            if root then
                                local fp = root .. "/" .. tostring(file)
                                local f = io.open(fp, "r")
                                if f then
                                    vim.g.diffview_undo_backup = {
                                        file = tostring(file),
                                        content = f:read("*a"),
                                        timestamp = os.time()
                                    }; f:close()
                                end
                            end
                            vim.cmd("!git checkout -p -- " ..
                                        vim.fn.shellescape(file))
                            vim.cmd("DiffviewRefresh")
                        end,
                        ["gD"] = function()
                            local file = file_at_cursor()
                            if not file then return end
                            local root = git_root()
                            if root then
                                local fp = root .. "/" .. tostring(file)
                                local f = io.open(fp, "r")
                                if f then
                                    vim.g.diffview_undo_backup = {
                                        file = tostring(file),
                                        content = f:read("*a"),
                                        timestamp = os.time()
                                    }; f:close()
                                end
                            end
                            run_git({"checkout", "--", file})
                            vim.cmd("DiffviewRefresh")
                        end,
                        ["gS"] = function()
                            local file = file_at_cursor()
                            if not file then return end
                            vim.cmd("!git add -p -- " ..
                                        vim.fn.shellescape(file))
                            vim.cmd("DiffviewRefresh")
                        end,
                        ["<leader>hU"] = function()
                            local b = vim.g.diffview_undo_backup
                            if not b or not b.content then
                                vim.notify("No backup to restore",
                                    vim.log.levels.WARN)
                                return
                            end
                            local file = file_at_cursor()
                            if not file then return end
                            if tostring(b.file) ~= tostring(file) then
                                vim.notify("File mismatch. Backup is for: " ..
                                    tostring(b.file), vim.log.levels.WARN)
                                return
                            end
                            local root = git_root()
                            if not root then return end
                            local fp = root .. "/" .. tostring(file)
                            local f = io.open(fp, "w")
                            if f then
                                f:write(b.content); f:close()
                                vim.cmd("DiffviewRefresh")
                                vim.notify("Restored file from backup")
                            else
                                vim.notify("Cannot write: " .. fp,
                                    vim.log.levels.ERROR)
                            end
                        end,
                        -- Visual mode: revert selected lines
                        { "v", "<leader>hu", function()
                            local file = file_at_cursor()
                            if not file then return end
                            local root = git_root()
                            if not root then return end

                            local fp = root .. "/" .. tostring(file)
                            local f = io.open(fp, "r")
                            if f then
                                vim.g.diffview_undo_backup = {
                                    file = tostring(file),
                                    content = f:read("*a"),
                                    timestamp = os.time()
                                }; f:close()
                            end

                            local s = math.min(vim.fn.line("."),
                                               vim.fn.line("v"))
                            local e = math.max(vim.fn.line("."),
                                               vim.fn.line("v"))

                            local diff = vim.fn.systemlist({
                                "git", "-C", root, "diff",
                                "-U1",
                                "-L" .. s .. "," .. e .. ":" ..
                                    tostring(file),
                                "--", tostring(file)
                            })

                            if #diff > 1 then
                                local tmp = os.tmpname()
                                local fw = io.open(tmp, "w")
                                if fw then
                                    fw:write(table.concat(diff, "\n"))
                                    fw:close()
                                    vim.fn.system({
                                        "git", "-C", root,
                                        "apply", "-R", tmp
                                    })
                                    os.remove(tmp)
                                end
                                vim.cmd("DiffviewRefresh")
                                vim.notify(string.format(
                                    "Reverted lines %d-%d. '<leader>hU' to redo.",
                                    s, e))
                            else
                                vim.notify("No changes to revert in selected range",
                                    vim.log.levels.INFO)
                            end
                        end},
                    },
                    file_panel = {
                        ["j"] = actions.next_entry,
                        ["k"] = actions.prev_entry,
                        ["<CR>"] = actions.select_entry,
                        ["o"] = actions.select_entry,
                        ["<2-LeftMouse>"] = actions.select_entry,
                        ["-"] = actions.toggle_stage_entry,
                        ["S"] = actions.stage_all,
                        ["U"] = actions.unstage_all,
                        ["X"] = actions.restore_entry,
                        ["R"] = actions.refresh_files,
                        ["L"] = actions.open_commit_log,
                        ["<Tab>"] = actions.select_next_entry,
                        ["<S-Tab>"] = actions.select_prev_entry,
                        ["gf"] = actions.goto_file,
                        ["<C-w><C-f>"] = actions.goto_file_split,
                        ["<C-w>gf"] = actions.goto_file_tab,
                        ["i"] = actions.listing_style,
                        ["f"] = actions.toggle_flatten_dirs,
                        ["<leader>e"] = actions.focus_files,
                        ["<leader>b"] = actions.toggle_files,
                        ["g<C-x>"] = actions.cycle_layout,
                        ["[x"] = actions.prev_conflict,
                        ["]x"] = actions.next_conflict,
                        ["<Esc>"] = actions.close,
                        ["q"] = actions.close,
                    },
                    file_history_panel = {
                        ["g!"] = actions.options,
                        ["<C-A-d>"] = actions.open_in_diffview,
                        ["y"] = actions.copy_hash,
                        ["L"] = actions.open_commit_log,
                        ["zR"] = actions.open_all_folds,
                        ["zM"] = actions.close_all_folds,
                        ["j"] = actions.next_entry,
                        ["k"] = actions.prev_entry,
                        ["<CR>"] = actions.select_entry,
                        ["o"] = actions.select_entry,
                        ["<2-LeftMouse>"] = actions.select_entry,
                        ["<Tab>"] = actions.select_next_entry,
                        ["<S-Tab>"] = actions.select_prev_entry,
                        ["gf"] = actions.goto_file,
                        ["<C-w><C-f>"] = actions.goto_file_split,
                        ["<C-w>gf"] = actions.goto_file_tab,
                        ["<leader>e"] = actions.focus_files,
                        ["<leader>b"] = actions.toggle_files,
                        ["g<C-x>"] = actions.cycle_layout,
                        ["<Esc>"] = actions.close,
                        ["q"] = actions.close,
                    },
                    option_panel = {
                        ["<Tab>"] = actions.select_entry,
                        ["q"] = actions.close,
                        ["<Esc>"] = actions.close
                    }
                }
            })

            -- Global keymaps
            local map = vim.keymap.set
            map("n", "<leader>gv", "<cmd>DiffviewOpen<CR>",
                {desc = "Open Diffview"})
            map("n", "<leader>gV", "<cmd>DiffviewClose<CR>",
                {desc = "Close Diffview"})
            map("n", "<leader>gh", "<cmd>DiffviewFileHistory<CR>",
                {desc = "Git file history (all)"})
            map("n", "<leader>gf", "<cmd>DiffviewFileHistory %<CR>",
                {desc = "Git file history (current file)"})
            map("n", "<leader>gl", function()
                vim.ui.input({prompt = "Git log (branch/commit): "},
                             function(input)
                    if input and input ~= "" then
                        local ok, err = pcall(vim.cmd, "DiffviewOpen " .. input)
                        if not ok then
                            vim.notify("Invalid git reference: " .. input,
                                       vim.log.levels.ERROR)
                        end
                    end
                end)
            end, {desc = "Git log (custom)"})

            -- Render a footer with the undo / git-add / navigation shortcuts
            -- at the bottom of the Diffview file and file-history panels.
            local function diffview_footer(panel, mode)
                local data = panel.render_data
                if not data then return end

                -- Diffview creates a fresh root component on every
                -- `update_components` call, so attach the footer to the newest
                -- root to guarantee it renders after the section/file lists.
                local root = data.components[#data.components]
                if not root then return end

                local footer = panel.footer_comp
                if not footer or footer.parent ~= root then
                    footer = root:create_component()
                    panel.footer_comp = footer
                end
                footer:clear()

                local KEY = "DiffviewFilePanelSelected"
                local DESC = "DiffviewFilePanelPath"
                local TITLE = "DiffviewFilePanelTitle"
                local SEP = "DiffviewNonText"
                local PAD = "       "

                local function group(label, items)
                    footer:add_text(label, TITLE)
                    for _, item in ipairs(items) do
                        footer:add_text("  " .. item[1], KEY)
                        footer:add_text(" " .. item[2], DESC)
                    end
                    footer:ln()
                end

                local function group_cont(items)
                    footer:add_text(PAD, SEP)
                    for _, item in ipairs(items) do
                        footer:add_text("  " .. item[1], KEY)
                        footer:add_text(" " .. item[2], DESC)
                    end
                    footer:ln()
                end

                footer:add_line(string.rep("─", 34), SEP)
                footer:add_text("  Shortcuts", TITLE)
                footer:ln()

                if mode == "file_history_panel" then
                    group("Undo ", {{"X", "restore file"}})
                    group("View ", {{"g!", "options"}, {"y", "copy hash"}, {"<C-A-d>", "diffview"}})
                    group("Nav  ", {{"j/k", "move"}, {"<CR>", "open"}, {"L", "log"}, {"g?", "help"}})
                else
                    group("Undo ", {{"X", "revert"}, {"gD", "discard"}, {"gd", "hunk"}})
                    group_cont({{"<leader>hU", "redo"}})
                    group("Stage", {{"-/+", "toggle"}, {"S", "all"}, {"U", "unstage"}})
                    group_cont({{"gS", "add -p"}})
                    group("Files", {{"j/k", "move"}, {"<CR>", "open"}, {"R", "refresh"}})
                    group("More ", {{"f", "flat"}, {"i", "list"}, {"L", "log"}, {"g?", "help"}})
                end

                footer:add_line(string.rep("─", 34), SEP)
            end

            if not vim.g.diffview_footer_patched then
                vim.g.diffview_footer_patched = true
                local FilePanel = require(
                    "diffview.scene.views.diff.file_panel").FilePanel
                local orig_fp_render = FilePanel.render
                function FilePanel:render()
                    orig_fp_render(self)
                    diffview_footer(self, "file_panel")
                end

                local FHFilePanel = require(
                    "diffview.scene.views.file_history.file_history_panel")
                    .FileHistoryPanel
                local orig_fh_render = FHFilePanel.render
                function FHFilePanel:render()
                    orig_fh_render(self)
                    diffview_footer(self, "file_history_panel")
                end
            end
        end
    }, -- Keybinding Helper
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        config = function()
            require("which-key").setup({
                plugins = {
                    marks = true,
                    registers = true,
                    spelling = {enabled = false},
                    presets = {
                        operators = false,
                        motions = false,
                        text_objects = false,
                        windows = false,
                        nav = false,
                        z = false,
                        g = false
                    }
                },
                win = {padding = {1, 2}, wo = {winblend = 0}},
                layout = {
                    height = {min = 4, max = 25},
                    width = {min = 20, max = 50},
                    spacing = 3,
                    align = "left"
                },
                show_help = true,
                show_keys = true
            })
        end
    }, -- File Explorer
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {"nvim-tree/nvim-web-devicons", "echasnovski/mini.icons"},
        config = function()
            require("nvim-tree").setup({
                view = {width = 35, side = "left"},
                filters = {dotfiles = false},
                git = {enable = true, ignore = false},
                update_focused_file = {
                    enable = true,
                    update_root = true,
                    ignore_list = {}
                },
                actions = {
                    open_file = {
                        quit_on_open = false,
                        window_picker = {enable = false}
                    }
                },
                on_attach = function(bufnr)
                    local api = require("nvim-tree.api")
                    local function opts(desc)
                        return {
                            desc = "nvim-tree: " .. desc,
                            buffer = bufnr,
                            noremap = true,
                            silent = true,
                            nowait = true
                        }
                    end
                    -- Enter opens normally in current window
                    vim.keymap.set("n", "<CR>", function()
                        local node = api.tree.get_node_under_cursor()
                        if node then api.node.open.edit() end
                    end, opts("Open"))
                    -- 'o' opens in new tab with NvimTree
                    vim.keymap.set("n", "o", function()
                        local node = api.tree.get_node_under_cursor()
                        if node then
                            if node.type == "directory" then
                                api.node.open.edit()
                            else
                                -- Open file in new tab
                                api.node.open.tab()
                                -- Open NvimTree in the new tab
                                vim.defer_fn(function()
                                    vim.cmd("NvimTreeOpen")
                                end, 10)
                            end
                        end
                    end, opts("Open in Tab with NvimTree"))
                end,
                renderer = {
                    highlight_opened_files = "all", -- Highlight all open files
                    indent_markers = {enable = true}
                }
            })
            -- Auto-open file tree on startup (when no session is being restored)
            vim.api.nvim_create_autocmd("VimEnter", {
                once = true,
                callback = function()
                    vim.defer_fn(function()
                        -- Only open if no session was auto-restored
                        local has_nvim_tree = false
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                            local buf = vim.api.nvim_win_get_buf(win)
                            if vim.bo[buf].filetype == "NvimTree" then
                                has_nvim_tree = true
                                break
                            end
                        end
                        if not has_nvim_tree then
                            vim.cmd("NvimTreeOpen")
                        end
                    end, 200)
                end
            })
        end
    }, -- Colorschemes
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "macchiato",
                integrations = {
                    nvimtree = true,
                    lualine = true,
                    gitsigns = true,
                    treesitter = true,
                    cmp = true
                }
            })
            -- Apply persisted theme if available (migrated into combined settings)
            do
                local settings = read_selected()
                if settings and settings.theme and settings.theme ~= "" then
                    local ok, _ = pcall(vim.cmd,
                                        "colorscheme " .. settings.theme)
                    if ok then return end
                end
            end
            if not pcall(vim.cmd, "colorscheme catppuccin-macchiato") then
                pcall(vim.cmd, "colorscheme catppuccin")
            end
        end
    }, {"folke/tokyonight.nvim", priority = 1000},
    {"rebelot/kanagawa.nvim", priority = 1000},
    {"EdenEast/nightfox.nvim", priority = 1000},
    {"navarasu/onedark.nvim", priority = 1000},
    {"rose-pine/neovim", name = "rose-pine", priority = 1000},
    {"Mofiqul/dracula.nvim", priority = 1000},
    {"ellisonleao/gruvbox.nvim", priority = 1000},
    {"sainnhe/everforest", priority = 1000},
    {"sainnhe/gruvbox-material", priority = 1000},
    {"projekt0n/github-nvim-theme", priority = 1000},
    {"marko-cerovac/material.nvim", priority = 1000},
    {"shaunsingh/nord.nvim", priority = 1000},
    {"bluz71/vim-nightfly-colors", name = "nightfly", priority = 1000},
    {"bluz71/vim-moonfly-colors", name = "moonfly", priority = 1000},
    {"Mofiqul/vscode.nvim", priority = 1000},
    -- Theme picker moved into main telescope config

    {
        "glepnir/lspsaga.nvim",
        event = "LspAttach",
        config = function()
            require("lspsaga").setup({
                lightbulb = {enable = false},
                symbol_in_winbar = {enable = false}
            })
        end
    }, -- Diagnostics Viewer
    {
        "folke/trouble.nvim",
        dependencies = {"nvim-tree/nvim-web-devicons"},
        config = function()
            require("trouble").setup({
                fold_open = "▾",
                fold_closed = "▸",
                signs = {
                    error = "✗",
                    warning = "⚠",
                    hint = "💡",
                    information = "ℹ"
                },
                use_diagnostic_signs = true
            })
        end
    }, -- Session Management
    {
        "rmagatti/auto-session",
        config = function()
            require("auto-session").setup({
                log_level = "error",
                auto_session_enable_last_session = true,
                auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
                auto_session_enabled = true,
                auto_save_enabled = true, -- Automatically save session on exit
                auto_restore_enabled = true, -- Automatically restore session on startup
                auto_session_suppress_dirs = nil,
                auto_session_use_git_branch = true, -- Separate sessions per git branch
                -- Save/restore window and tab layout
                pre_save_cmds = {"NvimTreeClose"},
                post_restore_cmds = {},
                -- Suppress errors during restore to prevent eslint errors from breaking session restore
                suppress_dirs = nil,
                session_lens = {
                    buftypes_to_ignore = {},
                    load_on_setup = true,
                    theme_conf = {border = true},
                    previewer = false
                },
                -- Allow sessions in all directories
                auto_session_allowed_dirs = nil,
                -- Exclude git and telescope buffers from sessions
                bypass_session_save_file_types = {
                    "gitcommit", "gitrebase", "NeogitStatus",
                    "NeogitCommitMessage", "DiffviewFiles", "help", "terminal"
                }
            })

            -- Ensure NvimTree opens after session restore in ALL tabs
            local function restore_nvim_tree_all_tabs()
                vim.schedule(function()
                    if vim.fn.exists(":NvimTreeOpen") ~= 2 then
                        return
                    end

                    local current_tab = vim.fn.tabpagenr()
                    local total_tabs = vim.fn.tabpagenr("$")

                    -- Go through each tab and open NvimTree if not present
                    for tab = 1, total_tabs do
                        -- Use noautocmd to prevent triggering autocommands during tab switching
                        vim.cmd("noautocmd tabnext " .. tab)

                        -- Check if NvimTree already exists in this tab
                        local has_nvim_tree = false
                        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                            local buf = vim.api.nvim_win_get_buf(win)
                            if vim.bo[buf].filetype == "NvimTree" then
                                has_nvim_tree = true
                                break
                            end
                        end

                        -- Open NvimTree if not present
                        if not has_nvim_tree then
                            vim.cmd("NvimTreeOpen")
                        end
                    end

                    -- Return to original tab (without triggering autocommands)
                    vim.cmd("noautocmd tabnext " .. current_tab)

                    -- Trigger autocommands once at the end to update statusline etc.
                    vim.cmd("doautocmd BufEnter")
                end)
            end

            -- Close git/telescope windows before saving session
            vim.api.nvim_create_autocmd("User", {
                pattern = "AutoSessionSavePre",
                callback = function()
                    -- Close any Neogit, Diffview, Telescope, or Git Log windows
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        local ft = vim.bo[buf].filetype
                        local bufname = vim.api.nvim_buf_get_name(buf)
                        if ft == "NeogitStatus" or ft == "NeogitCommitMessage" or
                            ft == "DiffviewFiles" or ft == "TelescopePrompt" or
                            vim.bo[buf].buftype == "terminal" or
                            bufname:match("Git Log") then
                            pcall(vim.api.nvim_win_close, win, true)
                        end
                    end
                end
            })

            -- Handle auto-session restore events
            vim.api.nvim_create_autocmd("User", {
                pattern = "AutoSessionLoadPost",
                callback = restore_nvim_tree_all_tabs
            })

            vim.api.nvim_create_autocmd("SessionLoadPost",
                                        {callback = restore_nvim_tree_all_tabs})

            -- Fallback: ensure NvimTree opens after VimEnter if session was restored
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    vim.defer_fn(function()
                        -- Check if we have multiple tabs (indicates session was restored)
                        if vim.fn.tabpagenr("$") > 1 then
                            restore_nvim_tree_all_tabs()
                        end
                    end, 300)
                end
            })

            -- Keymaps for session management
            local map = vim.keymap.set
            map("n", "<leader>ss", "<cmd>AutoSession save<CR>",
                {desc = "Save session"})
            map("n", "<leader>sr", "<cmd>AutoSession restore<CR>",
                {desc = "Restore session"})
            map("n", "<leader>sd", "<cmd>AutoSession delete<CR>",
                {desc = "Delete session"})
            map("n", "<leader>sf", "<cmd>AutoSession search<CR>",
                {desc = "Search sessions"})
        end
    }, -- Dashboard / Alpha
    {
        "goolord/alpha-nvim",
        lazy = false,
        priority = 900,
        dependencies = {"nvim-tree/nvim-web-devicons"},
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            -- The Creation of Adam ASCII art
            dashboard.section.header.val = {
                "                                                                                                                                                                                             ",
                "                                                                                                                                                                                             ",
                "                                                                                                                                                                                        ###  ",
                "                                                                                                                                                                                    +++++++  ",
                "                                ++++++++                                                                                                                                         -++#+#   ++ ",
                "                            --#-#-+++++--#-#-#++-#-#-#-                                                                                                                       #-#-#-#-  # ++ ",
                "                        -#-#-#-#+#++-+#+#-#-#-#-#-#-#+#-+-+####+-                                                                                                 +#-+-#+#-#-#-#-#-#-##---+  ",
                "                    - #+#-# #-###+#++#+#+###-#-# #-#+#+#-#-+####+-#-  -                                                                                  - . #-+#-####+-# #+#-#+# #-#-#-#+#+ ",
                "                - #.#.# # # # . .   ##.#.#+### # # #.# # #.+#+-#.## # - .                                                                          . # # #.# # ##-++-#+ # #.#+# # # #++-#.#- ",
                "            -#+.#-#.#.#-# +     . . ##+#.###.# # #-#+# #-#.+#+-#+## # #+#.  .                                                                .   #.# #-#.#.#-#.+#-+++#+.# #+#.#-# #.###-#.#- ",
                "        .+##+#+-#-#+#.#.#-#--     .  -+#+###.#-#-#.#.#-#-#..#.##+-+-#+#+#.#-#                                                         .  --#+#+#.+.#-#-#.#+#-#-+.+##+#+-#-#+#.#.#-#.+.#+#+#- ",
                "    .#-+-#-##-+-++-+#-#-#-           -+--#-#-+-#-#-#                  #-#-#-#-.                                                    -#+#+-++-+#-#-#-+-#-#-#      -##-#-+-++#-#-#-#-+-#-#-#+-+ ",
                "-#---++#-#----#++++---#              -+--#-#-#---#-#                      #---#-#-                                             -#-#----+++++-----#-                -#-.                      ",
                "++++++++++++++++++++++++                 ++++++++++++++-                      .++++++                                        ++++++++++++++++++++++                                          ",
                "++++++++++++++++++++++                   ++++++++++++++++                        +++++                        +++++++++++++++++++++++++++++++++++++                                          ",
                "###################-                           ############.                       ###+                 ########################. .################                                          ",
                "###############                                  -############                       ###+         ###########           ######   ################                                            ",
                "#######                                                 ########                     .###       #####                    ##    +#######.######.                                              ",
                "####                                                      ########.                    -###                                   #######                                                        ",
                "####     . -    .       + -                                  .#########   + -   . -                                       # ####### -            + -   - +                                   ",
                "# # +   . .  . .     #                                      . -- .## # # + -   . -                                     # #.# # # . - +       .+ + . . -                                      ",
                "# + + +   . -.     +                                          -.   # # + + - + . -                                   + # #.#.- + + . -.+      + - . +                                        ",
                "- + + +   .--.                                               -..-  . # +   . +   . -                                 # # #.- - + + . - +      -.- .                                          ",
                "- - - -    ..                                                -..-    -     . -   -.                               .- - . - - . - - . . -    - -                                              ",
                ". - - -                                                                                                           .+ -   - - . - -   . -                                                     ",
                ". . . .                                                                                                                  ..  .       . .                                                     ",
                ". .                                                                                                                ..  ... .    ..                                                           ",
                ".                                                                                                                 ...   .. .                                                                 ",
                "                                                                                                                    --   --                                                                  ",
                "                                                                                                                    -   --                                                                   ",
                "                                                                                                                       -                                                                     "
            }

            dashboard.section.header.opts.hl = "Type"

            -- Set menu buttons (optional)
            dashboard.section.buttons.val = {}

            -- Set footer (optional)
            dashboard.section.footer.val = ""

            -- Layout
            dashboard.config.layout = {
                {
                    type = "padding",
                    val = vim.fn.max({
                        2, vim.fn.floor(vim.fn.winheight(0) * 0.2)
                    })
                }, dashboard.section.header, {type = "padding", val = 2},
                dashboard.section.buttons, dashboard.section.footer
            }

            alpha.setup(dashboard.config)

            -- Disable folding on alpha buffer
            vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
        end
    }, -- DeepSeek Chat
    {
        "nvim-lua/plenary.nvim" -- Already included, but ensuring it's available
    }, -- Incline.nvim for Floating Statuslines
    {
        "b0o/incline.nvim",
        config = function()
            require("incline").setup({
                window = {
                    margin = {vertical = 0, horizontal = 1},
                    padding = 1,
                    padding_char = " ",
                    placement = {vertical = "top", horizontal = "right"},
                    zindex = 60,
                    winhighlight = {
                        active = {
                            Normal = "NormalFloat",
                            FloatBorder = "FloatBorder"
                        },
                        inactive = {
                            Normal = "NormalFloat",
                            FloatBorder = "FloatBorder"
                        }
                    }
                },
                hide = {
                    cursorline = false,
                    focused_win = false,
                    only_win = false
                },
                render = function(props)
                    local filename = vim.fn.fnamemodify(vim.api
                                                            .nvim_buf_get_name(
                                                            props.buf), ":t")
                    if filename == "" then
                        filename = "[No Name]"
                    end

                    local ft_icon, ft_color =
                        require("nvim-web-devicons").get_icon_color(filename)
                    local modified = vim.bo[props.buf].modified and " ●" or ""

                    return {
                        {ft_icon, guifg = ft_color}, {" "},
                        {filename .. modified}
                    }
                end
            })

            -- Toggle keymap
            vim.keymap.set("n", "<leader>it", function()
                local incline = require("incline")
                if incline.is_enabled() then
                    incline.disable()
                else
                    incline.enable()
                end
            end, {desc = "Toggle Incline"})
        end
    }, -- Twilight.nvim for Context Highlighting
    {
        "folke/twilight.nvim",
        config = function()
            require("twilight").setup({
                dimming = {
                    alpha = 0.25,
                    color = {"Normal", "#ffffff"},
                    term_bg = "#000000",
                    inactive = false
                },
                context = 20,
                treesitter = true,
                expand = {
                    "function", "method", "table", "if_statement",
                    "import_statement", "export_statement"
                },
                exclude = {}
            })

            -- Toggle keymap
            vim.keymap.set("n", "<leader>ttw", "<cmd>Twilight<CR>",
                           {desc = "Toggle Twilight"})
            vim.keymap.set("n", "<leader>tth", "<cmd>TwilightEnable<CR>",
                           {desc = "Enable Twilight"})
            vim.keymap.set("n", "<leader>ttl", "<cmd>TwilightDisable<CR>",
                           {desc = "Disable Twilight"})
        end
    }, -- AI Commit Message Suggestions
    {
        "nvim-lua/plenary.nvim", -- Already included, but ensuring it's available
        config = function()
            -- Add nvim-general directory to package.path so we can require local files
            local config_path = vim.fn.expand("~/.config/nvim-general")
            package.path = package.path .. ";" .. config_path .. "/?.lua;" ..
                               config_path .. "/?/init.lua"

            -- Load AI commit plugin
            local ai_commit = require("ai-commit")
            ai_commit.setup({
                api_key = os.getenv("DEEPSEEK_API_KEY") or "",
                keymaps = {generate = "<leader>cg"}
            })

            -- Load URL monitor plugin
            local url_monitor = require("url-monitor")
            url_monitor.setup()
        end
    }, -- Vim-dadbod - Database interface (PostgreSQL + MongoDB support)
    {
        "tpope/vim-dadbod",
        dependencies = {
            "kristijanhusak/vim-dadbod-ui",
            "kristijanhusak/vim-dadbod-completion"
        },
        config = function()
            -- DB UI settings
            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_show_database_icon = 1
            vim.g.db_ui_force_echo_notifications = 1
            vim.g.db_ui_win_position = "right"
            vim.g.db_ui_winwidth = 40

            -- Save query history
            vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

            -- Persistent connections storage
            vim.g.db_ui_save_connections = 1
            vim.g.db_ui_tmp_query_location =
                vim.fn.stdpath("data") .. "/db_ui/tmp"

            -- Database support configuration
            -- PostgreSQL: Built-in support ✅
            -- MongoDB: Requires mongosh CLI (install: brew install mongosh)
            -- Connection examples:
            --   PostgreSQL: postgresql://user:password@localhost:5432/dbname
            --   MongoDB:    mongodb://localhost:27017/dbname
            --   MongoDB:    mongodb://user:password@localhost:27017/dbname

            -- Keymaps
            local map = vim.keymap.set
            map("n", "<leader>cdb", "<cmd>DBUIToggle<CR>",
                {desc = "Database: Toggle UI"})
            map("n", "<leader>cdba", "<cmd>DBUIAddConnection<CR>",
                {desc = "Database: Add connection"})
            map("n", "<leader>cdbf", "<cmd>DBUIFindBuffer<CR>",
                {desc = "Database: Find buffer"})
            map("n", "<leader>cdbn", "<cmd>DBUIRenameBuffer<CR>",
                {desc = "Database: Rename buffer"})
            map("n", "<leader>cdbi", "<cmd>DBUILastQueryInfo<CR>",
                {desc = "Database: Last query info"})

            -- Quick reconnect to saved connections
            map("n", "<leader>cdbr", function()
                local connections_file =
                    vim.fn.stdpath("config") .. "/db_ui_connections.json"

                -- Check if connections file exists
                if vim.fn.filereadable(connections_file) == 0 then
                    vim.notify(
                        "No saved connections found. Add connections first with <leader>cdba",
                        vim.log.levels.WARN)
                    return
                end

                -- Read and parse connections
                local file = io.open(connections_file, "r")
                if not file then
                    vim.notify("Could not read connections file",
                               vim.log.levels.ERROR)
                    return
                end

                local content = file:read("*a")
                file:close()

                local ok, connections = pcall(vim.json.decode, content)
                if not ok or not connections or #connections == 0 then
                    vim.notify("No valid connections found", vim.log.levels.WARN)
                    return
                end

                -- Use telescope to select connection
                local pickers = require("telescope.pickers")
                local finders = require("telescope.finders")
                local conf = require("telescope.config").values
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")

                pickers.new({}, {
                    prompt_title = "Select Database Connection",
                    finder = finders.new_table({
                        results = connections,
                        entry_maker = function(entry)
                            local display_name = entry.name or entry.url
                            return {
                                value = entry,
                                display = display_name,
                                ordinal = display_name
                            }
                        end
                    }),
                    sorter = conf.generic_sorter({}),
                    attach_mappings = function(prompt_bufnr)
                        actions.select_default:replace(function()
                            local selection = action_state.get_selected_entry()
                            actions.close(prompt_bufnr)

                            if selection then
                                -- Set the connection and open DBUI
                                vim.g.db = selection.value.url
                                vim.cmd("DBUIToggle")
                                vim.notify(
                                    "Connected to: " ..
                                        (selection.value.name or "database"),
                                    vim.log.levels.INFO)
                            end
                        end)
                        return true
                    end
                }):find()
            end, {desc = "Database: Reconnect (select from saved)"})

            -- Save current connection
            map("n", "<leader>cdbs", function()
                local connections_file =
                    vim.fn.stdpath("config") .. "/db_ui_connections.json"

                vim.ui.input({prompt = "Connection Name: "}, function(name)
                    if not name or name == "" then
                        vim.notify("Connection save cancelled",
                                   vim.log.levels.WARN)
                        return
                    end

                    vim.ui.input({prompt = "Connection URL: "}, function(url)
                        if not url or url == "" then
                            vim.notify("Connection save cancelled",
                                       vim.log.levels.WARN)
                            return
                        end

                        -- Read existing connections
                        local connections = {}
                        if vim.fn.filereadable(connections_file) == 1 then
                            local file = io.open(connections_file, "r")
                            if file then
                                local content = file:read("*a")
                                file:close()
                                local ok, data = pcall(vim.json.decode, content)
                                if ok and data then
                                    connections = data
                                end
                            end
                        end

                        -- Add new connection
                        table.insert(connections, {
                            name = name,
                            url = url,
                            added = os.date("%Y-%m-%d %H:%M:%S")
                        })

                        -- Save connections
                        local file = io.open(connections_file, "w")
                        if file then
                            file:write(vim.json.encode(connections))
                            file:close()
                            vim.notify("Connection '" .. name .. "' saved!",
                                       vim.log.levels.INFO)
                        else
                            vim.notify("Failed to save connection",
                                       vim.log.levels.ERROR)
                        end
                    end)
                end)
            end, {desc = "Database: Save connection"})

            -- List all saved connections
            map("n", "<leader>cdbL", function()
                local connections_file =
                    vim.fn.stdpath("config") .. "/db_ui_connections.json"

                if vim.fn.filereadable(connections_file) == 0 then
                    vim.notify("No saved connections", vim.log.levels.INFO)
                    return
                end

                local file = io.open(connections_file, "r")
                if not file then return end

                local content = file:read("*a")
                file:close()

                local ok, connections = pcall(vim.json.decode, content)
                if not ok or not connections or #connections == 0 then
                    vim.notify("No saved connections", vim.log.levels.INFO)
                    return
                end

                -- Display in a buffer
                local buf = vim.api.nvim_create_buf(false, true)
                local lines = {"Saved Database Connections:", ""}

                for i, conn in ipairs(connections) do
                    table.insert(lines, string.format("%d. %s", i, conn.name))
                    table.insert(lines, string.format("   URL: %s", conn.url))
                    table.insert(lines, string.format("   Added: %s",
                                                      conn.added or "unknown"))
                    table.insert(lines, "")
                end

                table.insert(lines, "")
                table.insert(lines, "Press q to close")
                table.insert(lines, "Use <leader>cdbr to reconnect")

                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                vim.api.nvim_buf_set_option(buf, "modifiable", false)
                vim.api.nvim_buf_set_option(buf, "buftype", "nofile")

                local win = vim.api.nvim_open_win(buf, true, {
                    relative = "editor",
                    width = math.floor(vim.o.columns * 0.8),
                    height = math.floor(vim.o.lines * 0.8),
                    col = math.floor(vim.o.columns * 0.1),
                    row = math.floor(vim.o.lines * 0.1),
                    style = "minimal",
                    border = "rounded",
                    title = " Saved Connections ",
                    title_pos = "center"
                })

                vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>",
                                            {noremap = true, silent = true})
            end, {desc = "Database: List saved connections"})

            -- Add dadbod completion to nvim-cmp
            vim.api.nvim_create_autocmd("FileType", {
                pattern = {"sql", "mysql", "plsql", "mongodb"},
                callback = function()
                    local cmp = require("cmp")
                    local sources = cmp.get_config().sources
                    table.insert(sources, {name = "vim-dadbod-completion"})
                    cmp.setup.buffer({sources = sources})
                end
            })

            -- Check for database CLI tools on startup
            vim.defer_fn(function()
                local has_psql = vim.fn.executable("psql") == 1
                local has_mongosh = vim.fn.executable("mongosh") == 1

                if not has_psql then
                    vim.notify(
                        "PostgreSQL client not found. Install: brew install postgresql",
                        vim.log.levels.WARN)
                end

                if not has_mongosh then
                    vim.notify(
                        "MongoDB Shell not found. Install: brew install mongosh",
                        vim.log.levels.WARN)
                end
            end, 1000)
        end
    }, -- Markdown Preview - Instant split view
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons"
        },
        ft = {"markdown"},
        config = function()
            require("render-markdown").setup({
                enabled = true,
                max_file_size = 1.5,
                debounce = 100,
                render_modes = {"n", "c"},
                anti_conceal = {
                    enabled = true,
                    ignore = {code_background = true, sign = true}
                },
                heading = {
                    enabled = true,
                    sign = true,
                    icons = {
                        "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 "
                    },
                    width = "full",
                    backgrounds = {
                        "RenderMarkdownH1Bg", "RenderMarkdownH2Bg",
                        "RenderMarkdownH3Bg", "RenderMarkdownH4Bg",
                        "RenderMarkdownH5Bg", "RenderMarkdownH6Bg"
                    },
                    foregrounds = {
                        "RenderMarkdownH1", "RenderMarkdownH2",
                        "RenderMarkdownH3", "RenderMarkdownH4",
                        "RenderMarkdownH5", "RenderMarkdownH6"
                    }
                },
                code = {
                    enabled = true,
                    sign = true,
                    style = "full",
                    width = "block",
                    left_pad = 2,
                    right_pad = 2,
                    border = "thin",
                    highlight = "RenderMarkdownCode"
                },
                bullet = {
                    enabled = true,
                    icons = {"●", "○", "◆", "◇"},
                    highlight = "RenderMarkdownBullet"
                }
            })

            -- Keymaps (only for markdown files)
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                callback = function()
                    local map = vim.keymap.set
                    map("n", "<leader>mt", "<cmd>RenderMarkdown toggle<CR>",
                        {buffer = true, desc = "Markdown: Toggle render"})
                    map("n", "<leader>me", "<cmd>RenderMarkdown enable<CR>",
                        {buffer = true, desc = "Markdown: Enable render"})
                    map("n", "<leader>md", "<cmd>RenderMarkdown disable<CR>",
                        {buffer = true, desc = "Markdown: Disable render"})
                end
            })
        end
    }, -- Undo Tree Visualization
    {
        "mbbill/undotree",
        config = function()
            -- Undotree settings
            vim.g.undotree_WindowLayout = 2
            vim.g.undotree_ShortIndicators = 1
            vim.g.undotree_SplitWidth = 35
            vim.g.undotree_SetFocusWhenToggle = 1
            vim.g.undotree_DiffAutoOpen = 1
            vim.g.undotree_DiffpanelHeight = 10
            vim.g.undotree_RelativeTimestamp = 1
            vim.g.undotree_HighlightChangedText = 1
            vim.g.undotree_HighlightSyntaxAdd = "DiffAdd"
            vim.g.undotree_HighlightSyntaxChange = "DiffChange"
            vim.g.undotree_HelpLine = 0

            -- Keymaps
            local map = vim.keymap.set
            map("n", "<leader>ut", "<cmd>UndotreeToggle<CR>",
                {desc = "Toggle Undo Tree"})
            map("n", "<leader>uf", "<cmd>Telescope undo<CR>",
                {desc = "Undo history (floating preview)"})
        end
    }, -- Indentation Guides
    {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("ibl").setup({
                indent = {char = "│"},
                scope = {enabled = false}
            })
        end
    }, -- Auto-close brackets and quotes
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup()
        end
    }, -- TODO/FIXME highlight
    {
        "folke/todo-comments.nvim",
        dependencies = {"nvim-lua/plenary.nvim"},
        event = "BufRead",
        config = function()
            require("todo-comments").setup({
                keywords = {
                    FIX = {icon = "", color = "error",
                           alt = {"FIXME", "BUG", "FIXIT", "ISSUE", "BUGFIX"}},
                    TODO = {icon = "", color = "info"},
                    HACK = {icon = "", color = "warning"},
                    WARN = {icon = "", color = "warning",
                            alt = {"WARNING", "XXX", "CAUTION", "DANGER"}},
                    PERF = {icon = "", color = "warning",
                            alt = {"OPTIM", "PERFORMANCE", "OPTIMIZE"}},
                    NOTE = {icon = "", color = "info",
                            alt = {"INFO", "HINT", "TIP", "NOTICE"}},
                    TEST = {icon = "", color = "test",
                            alt = {"TESTING", "PASS", "FAIL"}},
                },
                merge_keywords = true,
            })
        end
    }, -- LSP progress spinner
    {
        "j-hui/fidget.nvim",
        config = function()
            require("fidget").setup({})
        end
    },
}

-- Reapply persisted theme on VimEnter in case plugin/theme load order changed
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local settings = read_selected()

        if settings and settings.theme and settings.theme ~= "" and
            settings.theme ~= vim.g.colors_name then
            local ok, _ = pcall(vim.cmd, "colorscheme " .. settings.theme)
            if not ok then
                vim.notify("Failed to reapply persisted theme: " ..
                               settings.theme, vim.log.levels.WARN)
            end
        end
    end
})
