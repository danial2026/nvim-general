-- =======================================================
-- Neovim Configuration for React.js & Next.js Development
-- =======================================================
--
-- "For I know the plans I have for you," declares the Lord, "plans to prosper you and not to harm you, plans to give you hope and a future." - Jeremiah 29:11
--
-- Bootstrap Lazy.nvim Plugin Manager (needed before loading plugins)
-- ===================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from general config
-- ==================================
-- Load the general config early to access the global plugins table
local home_dir = vim.fn.expand("~")
local general_config_path = home_dir .. "/.config/nvim-general/plugins.lua"
local general_plugins = {}
local ok, err = pcall(function()
    dofile(general_config_path)
    general_plugins = plugins or {}
end)
if not ok then
    vim.notify("Could not load general config: " .. tostring(err),
               vim.log.levels.ERROR)
end

-- Plugin Configuration
-- =====================
require("lazy").setup({
    -- Plugins from general config (loaded without importing entire file)
    general_plugins
})

-- Import general Neovim configuration
-- ====================================
local home_dir = vim.fn.expand("~")
dofile(home_dir .. "/.config/nvim-general/config.lua")

-- Neoterm Configuration
-- =====================
vim.g.neoterm_size = tostring(math.floor(0.4 * vim.o.columns))
vim.g.neoterm_default_mod = 'botright vertical'
vim.g.neoterm_autoinsert = 1
