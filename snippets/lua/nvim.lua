-- Lua snippets for Neovim configuration
-- Organized and consistent snippet definitions
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

-- All Lua/Neovim snippets in one efficient call
ls.add_snippets("lua", {
    -- ============================================
    -- Plugin Configuration Snippets
    -- ============================================

    -- Plugin setup snippet
    s({trig = "setup", dscr = "Plugin setup"}, fmt([[
local {} = require("{}")

{}.setup({{
    {}
}})
]], {i(1, "plugin"), rep(1), rep(1), i(2, "-- configuration options")})),

    -- Plugin configuration with lazy.nvim format
    s({trig = "pluginconf", dscr = "Lazy.nvim plugin config"}, fmt([[
return {{
    "{}",
    config = function()
        require("{}").setup({{
            {}
        }})
    end,
    {}
}}
]], {
        i(1, "author/plugin"), i(2, "plugin"), i(3, "-- plugin options"),
        i(4, "-- lazy.nvim options")
    })), -- ============================================
    -- Keymapping Snippets
    -- ============================================
    -- Basic keymap
    s({trig = "keymap", dscr = "Basic keymap"}, fmt([[
vim.keymap.set("{}", "{}", {}, {{ desc = "{}" }})
]], {i(1, "n"), i(2, "<leader>k"), i(3, "function() end"), i(4, "Description")})),

    -- Keymap with function
    s({trig = "keymapfn", dscr = "Keymap with function body"}, fmt([[
vim.keymap.set("{}", "{}", function()
    {}
end, {{ desc = "{}" }})
]], {
        i(1, "n"), i(2, "<leader>k"), i(3, "-- function body"),
        i(4, "Description")
    })), -- Buffer-local keymap
    s({trig = "keymapbuf", dscr = "Buffer-local keymap"}, fmt([[
vim.keymap.set("{}", "{}", {}, {{ buffer = {}, desc = "{}" }})
]], {
        i(1, "n"), i(2, "<leader>k"), i(3, "function() end"), i(4, "true"),
        i(5, "Description")
    })), -- ============================================
    -- Autocommand Snippets
    -- ============================================
    -- Basic autocommand
    s({trig = "autocmd", dscr = "Autocommand"}, fmt([[
vim.api.nvim_create_autocmd("{}", {{
    pattern = "{}",
    callback = function()
        {}
    end
}})
]], {i(1, "BufEnter"), i(2, "*"), i(3, "-- autocmd body")})),

    -- Autocommand with group
    s({trig = "autocmdgrp", dscr = "Autocommand with group"}, fmt([[
local {} = vim.api.nvim_create_augroup("{}", {{ clear = true }})

vim.api.nvim_create_autocmd("{}", {{
    group = {},
    pattern = "{}",
    callback = function()
        {}
    end
}})
]], {
        i(1, "group"), i(2, "GroupName"), i(3, "BufEnter"), rep(1), i(4, "*"),
        i(5, "-- autocmd body")
    })), -- ============================================
    -- Function Snippets
    -- ============================================
    -- Local function
    s({trig = "func", dscr = "Local function"}, fmt([[
local function {}({})
    {}
end
]], {i(1, "function_name"), i(2, "args"), i(3, "-- function body")})),

    -- Module function
    s({trig = "modfunc", dscr = "Module function"}, fmt([[
function M.{}({})
    {}
end
]], {i(1, "function_name"), i(2, "args"), i(3, "-- function body")})),

    -- Anonymous function
    s({trig = "fn", dscr = "Anonymous function"}, fmt([[
function({})
    {}
end
]], {i(1, "args"), i(2, "-- function body")})),

    -- ============================================
    -- Module and Require Snippets
    -- ============================================

    -- Module require
    s({trig = "req", dscr = "Require module"}, fmt([[
local {} = require("{}")
]], {i(1, "module"), i(2, "module.path")})), -- Module definition
    s({trig = "mod", dscr = "Module definition"}, fmt([[
local M = {{}}

{}

return M
]], {i(1, "-- module content")})), -- Lazy require (pcall)
    s({trig = "reqsafe", dscr = "Safe require with pcall"}, fmt([[
local ok, {} = pcall(require, "{}")
if not ok then
    {}
    return
end
]], {
        i(1, "module"), i(2, "module.path"),
        i(3, 'vim.notify("Failed to load module", vim.log.levels.ERROR)')
    })), -- ============================================
    -- Control Flow Snippets
    -- ============================================
    -- If statement
    s({trig = "if", dscr = "If statement"}, fmt([[
if {} then
    {}
end
]], {i(1, "condition"), i(2, "-- if body")})), -- If-else statement
    s({trig = "ifelse", dscr = "If-else statement"}, fmt([[
if {} then
    {}
else
    {}
end
]], {i(1, "condition"), i(2, "-- if body"), i(3, "-- else body")})),

    -- For loop (ipairs)
    s({trig = "fori", dscr = "For loop with ipairs"}, fmt([[
for {}, {} in ipairs({}) do
    {}
end
]], {i(1, "i"), i(2, "value"), i(3, "table"), i(4, "-- loop body")})),

    -- For loop (pairs)
    s({trig = "forp", dscr = "For loop with pairs"}, fmt([[
for {}, {} in pairs({}) do
    {}
end
]], {i(1, "key"), i(2, "value"), i(3, "table"), i(4, "-- loop body")})),

    -- Numeric for loop
    s({trig = "forn", dscr = "Numeric for loop"}, fmt([[
for {} = {}, {} do
    {}
end
]], {i(1, "i"), i(2, "1"), i(3, "10"), i(4, "-- loop body")})), -- While loop
    s({trig = "while", dscr = "While loop"}, fmt([[
while {} do
    {}
end
]], {i(1, "condition"), i(2, "-- loop body")})),

    -- ============================================
    -- Data Structure Snippets
    -- ============================================

    -- Table definition
    s({trig = "table", dscr = "Table definition"}, fmt([[
local {} = {{
    {}
}}
]], {i(1, "table_name"), i(2, "-- table contents")})), -- Array table
    s({trig = "array", dscr = "Array table"}, fmt([[
local {} = {{
    {},
}}
]], {i(1, "array_name"), i(2, "-- array elements")})),

    -- ============================================
    -- Debug and Error Handling Snippets
    -- ============================================

    -- Print debug
    s({trig = "print", dscr = "Print with vim.inspect"}, fmt([[
print("{}: ", vim.inspect({}))
]], {i(1, "debug"), i(2, "variable")})), -- Vim notify
    s({trig = "notify", dscr = "vim.notify"}, fmt([[
vim.notify("{}", vim.log.levels.{})
]], {i(1, "message"), i(2, "INFO")})), -- Protected call (pcall)
    s({trig = "pcall", dscr = "Protected call with pcall"}, fmt([[
local ok, {} = pcall(function()
    {}
end)

if not ok then
    vim.notify("Error: " .. tostring({}), vim.log.levels.ERROR)
end
]], {i(1, "result"), i(2, "-- protected code"), rep(1)})), -- Try-catch pattern
    s({trig = "try", dscr = "Try-catch pattern with pcall"}, fmt([[
local ok, {} = pcall(function()
    {}
end)

if ok then
    {}
else
    {}
end
]], {
        i(1, "result"), i(2, "-- try block"), i(3, "-- success handling"),
        i(4, "-- error handling")
    })), -- ============================================
    -- Neovim API Snippets
    -- ============================================
    -- Generic nvim API call
    s({trig = "nvim", dscr = "Neovim API call"}, fmt([[
vim.api.nvim_{}({})
]], {i(1, "command"), i(2, "args")})), -- Buffer API call
    s({trig = "nvimbuf", dscr = "Buffer API call"}, fmt([[
vim.api.nvim_buf_{}({}, {})
]], {i(1, "command"), i(2, "bufnr"), i(3, "args")})), -- Window API call
    s({trig = "nvimwin", dscr = "Window API call"}, fmt([[
vim.api.nvim_win_{}({}, {})
]], {i(1, "command"), i(2, "winnr"), i(3, "args")})), -- Set option
    s({trig = "opt", dscr = "Set vim option"}, fmt([[
vim.opt.{} = {}
]], {i(1, "option"), i(2, "value")})), -- Set global variable
    s({trig = "vimglobal", dscr = "Set global variable"}, fmt([[
vim.g.{} = {}
]], {i(1, "variable"), i(2, "value")})),

    -- ============================================
    -- Command Snippets
    -- ============================================

    -- Create user command
    s({trig = "cmd", dscr = "Create user command"}, fmt([[
vim.api.nvim_create_user_command("{}", function({})
    {}
end, {{ {} }})
]], {
        i(1, "CommandName"), i(2, "args"), i(3, "-- command body"),
        i(4, "desc = 'Command description'")
    })), -- ============================================
    -- Highlight Snippets
    -- ============================================
    -- Set highlight group
    s({trig = "hl", dscr = "Set highlight group"}, fmt([[
vim.api.nvim_set_hl(0, "{}", {{ {} }})
]], {i(1, "HighlightGroup"), i(2, "fg = '#ffffff', bg = '#000000'")})),

    -- ============================================
    -- Utility Snippets
    -- ============================================

    -- Schedule function
    s({trig = "schedule", dscr = "vim.schedule"}, fmt([[
vim.schedule(function()
    {}
end)
]], {i(1, "-- scheduled code")})), -- Defer function
    s({trig = "defer", dscr = "vim.defer_fn"}, fmt([[
vim.defer_fn(function()
    {}
end, {})
]], {i(1, "-- deferred code"), i(2, "100")})), -- File type check
    s({trig = "ftcheck", dscr = "Filetype check"}, fmt([[
if vim.bo.filetype == "{}" then
    {}
end
]], {i(1, "lua"), i(2, "-- filetype-specific code")})), -- Get current buffer
    s({trig = "curbuf", dscr = "Get current buffer"}, fmt([[
local {} = vim.api.nvim_get_current_buf()
]], {i(1, "bufnr")})), -- Get current window
    s({trig = "curwin", dscr = "Get current window"}, fmt([[
local {} = vim.api.nvim_get_current_win()
]], {i(1, "winnr")})), -- Get buffer lines
    s({trig = "getlines", dscr = "Get buffer lines"}, fmt([[
local {} = vim.api.nvim_buf_get_lines({}, {}, {}, {})
]], {i(1, "lines"), i(2, "0"), i(3, "0"), i(4, "-1"), i(5, "false")})),

    -- Set buffer lines
    s({trig = "setlines", dscr = "Set buffer lines"}, fmt([[
vim.api.nvim_buf_set_lines({}, {}, {}, {}, {})
]], {i(1, "0"), i(2, "0"), i(3, "-1"), i(4, "false"), i(5, "lines")}))
})
