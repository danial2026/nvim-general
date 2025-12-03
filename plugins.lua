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
    {"hrsh7th/cmp-path"}, -- File and Text Search, Terminal Management
    {"kassio/neoterm"}, -- UI Components for inputs
    {"MunifTanjim/nui.nvim"}, -- File and Text Search
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.6",
        dependencies = {"nvim-lua/plenary.nvim"},
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
                        "coverage/", ".turbo/", ".vercel/", "out/"
                    }
                }
            })

            -- Keymaps for searching
            local map = vim.keymap.set

            -- Search in all files in current directory
            map("n", "<leader>ff", builtin.find_files,
                {desc = "Find files in current directory"})
            map("n", "<leader>fg", builtin.live_grep,
                {desc = "Grep text in all files (current directory)"})

            -- Search all keymaps/commands
            map("n", "<leader>fc", builtin.keymaps,
                {desc = "Search all keymaps/commands"})

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
                numhl = false,
                linehl = false,
                word_diff = false,
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
                    map("v", "<leader>hs", function()
                        gs.stage_hunk({vim.fn.line("."), vim.fn.line("v")})
                    end, {desc = "Stage selected hunk"})
                    map("v", "<leader>hr", function()
                        gs.reset_hunk({vim.fn.line("."), vim.fn.line("v")})
                    end, {desc = "Reset selected hunk"})
                    map("n", "<leader>hS", gs.stage_buffer,
                        {desc = "Stage buffer"})
                    map("n", "<leader>hu", gs.undo_stage_hunk,
                        {desc = "Undo stage hunk"})
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

            -- Git commit (fixed to use proper API)
            map("n", "<leader>gc",
                function() require("neogit").open({"commit"}) end,
                {desc = "Git commit"})

            -- Git push/pull (fixed to use proper API)
            map("n", "<leader>gp",
                function() require("neogit").open({"push"}) end,
                {desc = "Git push"})
            map("n", "<leader>gP",
                function() require("neogit").open({"pull"}) end,
                {desc = "Git pull"})

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
                        ["<Tab>"] = require("diffview.actions").select_next_entry,
                        ["<S-Tab>"] = require("diffview.actions").select_prev_entry,
                        ["gf"] = require("diffview.actions").goto_file,
                        ["<C-w><C-f>"] = require("diffview.actions").goto_file_split,
                        ["<C-w>gf"] = require("diffview.actions").goto_file_tab,
                        ["<leader>e"] = require("diffview.actions").focus_files,
                        ["<leader>b"] = require("diffview.actions").toggle_files,
                        ["g<C-x>"] = require("diffview.actions").cycle_layout,
                        ["[x"] = require("diffview.actions").prev_conflict,
                        ["]x"] = require("diffview.actions").next_conflict,
                        ["<Esc>"] = require("diffview.actions").close,
                        ["q"] = require("diffview.actions").close
                    },
                    file_panel = {
                        ["j"] = require("diffview.actions").next_entry,
                        ["k"] = require("diffview.actions").prev_entry,
                        ["<CR>"] = require("diffview.actions").select_entry,
                        ["o"] = require("diffview.actions").select_entry,
                        ["<2-LeftMouse>"] = require("diffview.actions").select_entry,
                        ["-"] = require("diffview.actions").toggle_stage_entry,
                        ["S"] = require("diffview.actions").stage_all,
                        ["U"] = require("diffview.actions").unstage_all,
                        ["X"] = require("diffview.actions").restore_entry,
                        ["R"] = require("diffview.actions").refresh_files,
                        ["L"] = require("diffview.actions").open_commit_log,
                        ["<Tab>"] = require("diffview.actions").select_next_entry,
                        ["<S-Tab>"] = require("diffview.actions").select_prev_entry,
                        ["gf"] = require("diffview.actions").goto_file,
                        ["<C-w><C-f>"] = require("diffview.actions").goto_file_split,
                        ["<C-w>gf"] = require("diffview.actions").goto_file_tab,
                        ["i"] = require("diffview.actions").listing_style,
                        ["f"] = require("diffview.actions").toggle_flatten_dirs,
                        ["<leader>e"] = require("diffview.actions").focus_files,
                        ["<leader>b"] = require("diffview.actions").toggle_files,
                        ["g<C-x>"] = require("diffview.actions").cycle_layout,
                        ["[x"] = require("diffview.actions").prev_conflict,
                        ["]x"] = require("diffview.actions").next_conflict,
                        ["<Esc>"] = require("diffview.actions").close,
                        ["q"] = require("diffview.actions").close
                    },
                    file_history_panel = {
                        ["g!"] = require("diffview.actions").options,
                        ["<C-A-d>"] = require("diffview.actions").open_in_diffview,
                        ["y"] = require("diffview.actions").copy_hash,
                        ["L"] = require("diffview.actions").open_commit_log,
                        ["zR"] = require("diffview.actions").open_all_folds,
                        ["zM"] = require("diffview.actions").close_all_folds,
                        ["j"] = require("diffview.actions").next_entry,
                        ["k"] = require("diffview.actions").prev_entry,
                        ["<CR>"] = require("diffview.actions").select_entry,
                        ["o"] = require("diffview.actions").select_entry,
                        ["<2-LeftMouse>"] = require("diffview.actions").select_entry,
                        ["<Tab>"] = require("diffview.actions").select_next_entry,
                        ["<S-Tab>"] = require("diffview.actions").select_prev_entry,
                        ["gf"] = require("diffview.actions").goto_file,
                        ["<C-w><C-f>"] = require("diffview.actions").goto_file_split,
                        ["<C-w>gf"] = require("diffview.actions").goto_file_tab,
                        ["<leader>e"] = require("diffview.actions").focus_files,
                        ["<leader>b"] = require("diffview.actions").toggle_files,
                        ["g<C-x>"] = require("diffview.actions").cycle_layout,
                        ["<Esc>"] = require("diffview.actions").close,
                        ["q"] = require("diffview.actions").close
                    },
                    option_panel = {
                        ["<Tab>"] = require("diffview.actions").select_entry,
                        ["q"] = require("diffview.actions").close,
                        ["<Esc>"] = require("diffview.actions").close
                    }
                }
            })

            -- Keymaps
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
    }, -- Colorscheme
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
            vim.cmd.colorscheme("catppuccin")
        end
    }, -- LSP UI (Lspsaga)
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
    }
}
