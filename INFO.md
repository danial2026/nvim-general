# Info

## Installed Plugins

### Code Completion & LSP
- **nvim-cmp** - Completion engine
- **cmp-nvim-lsp** - LSP source
- **cmp-buffer** - Buffer completions
- **cmp-path** - Path completions
- **lspsaga.nvim** - LSP UI (hover, definition, rename)
- **trouble.nvim** - Diagnostics viewer

### Snippets
- **LuaSnip** - Snippet engine
- **friendly-snippets** - Snippet collection
- **Custom snippets** - 340+ for Dart, Lua, JS, TS, Go

### File Navigation & Search
- **telescope.nvim** - Fuzzy finder
- **telescope-undo.nvim** - Undo history browser
- **Theme Picker** - Live theme browser & preview
- **nvim-tree.lua** - File explorer
- **which-key.nvim** - Keybinding helper

### Git Integration
- **gitsigns.nvim** - Git signs in gutter, VS Code-style inline diff (numhl, word diff)
- **neogit** - Git interface
- **diffview.nvim** - Git diff viewer

### Terminal
- **neoterm** - Terminal management

### UI & Appearance
- **catppuccin** - Colorscheme
- **lualine.nvim** - Statusline
- **incline.nvim** - Floating statusline
- **alpha-nvim** - Dashboard
- **twilight.nvim** - Dim inactive code

### Database
- **vim-dadbod** - Database interface
- **vim-dadbod-ui** - Database UI
- **vim-dadbod-completion** - SQL completion

### Markdown
- **render-markdown.nvim** - Live markdown rendering

### Comments
- **Comment.nvim** - Easy commenting

### Sessions
- **auto-session** - Session management

### AI Tools
- **AI Commit Generator** - DeepSeek AI commit messages
- **DeepSeek Chat** - Chat with AI in Neovim

### Utilities
- **nui.nvim** - UI component library
- **plenary.nvim** - Lua utilities
- **undotree** - Visual undo tree
- **indent-blankline.nvim** - Indentation guides
- **nvim-autopairs** - Auto-close brackets
- **todo-comments.nvim** - TODO/FIXME highlighting and search
- **fidget.nvim** - LSP progress spinner

### URL Monitoring
- **URL Monitor** - Ping and monitor URLs

---

## Configuration

### File Locations
```
~/.config/nvim-general/
├── config.lua              # General settings, keymaps
├── plugins.lua             # All plugin configurations
├── ai-commit.lua           # AI commit generator
├── commit-rules.lua        # Commit message rules
├── url-monitor.lua         # URL ping monitor
├── SHORTCUTS.md            # Keymap reference
├── INFO.md                 # This file
├── README.md               # Overview
├── db_ui_connections.json  # Saved database connections
└── snippets/               # Custom snippets
    ├── dart/
    ├── lua/
    ├── javascript/
    ├── typescript/
    └── go/
```

### Main Settings (config.lua)
Leader key is Space.

```lua
vim.opt.number = true          -- Line numbers
vim.opt.signcolumn = "yes"     -- Always show sign column
vim.opt.tabstop = 2            -- Tab size
vim.opt.shiftwidth = 2         -- Indent size
vim.opt.expandtab = true       -- Spaces instead of tabs
vim.opt.termguicolors = true   -- True color support
vim.opt.cursorline = true      -- Highlight current line
```

### Plugin Settings (plugins.lua)

**Database UI:**
```lua
vim.g.db_ui_win_position = "right"
vim.g.db_ui_winwidth = 40
vim.g.db_ui_use_nerd_fonts = 1
```

**Markdown rendering:**
```lua
require("render-markdown").setup({
    enabled = true,
    heading = { icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " } },
    code = { border = "thin" },
    bullet = { icons = { "●", "○", "◆", "◇" } },
})
```

**Telescope:**
```lua
telescope.setup({
    defaults = {
        file_ignore_patterns = {
            "node_modules/", ".git/", "build/", "dist/",
        }
    }
})
```

**NvimTree:**
```lua
require("nvim-tree").setup({
    view = { width = 35, side = "left" },
    filters = { dotfiles = false },
})
```

### Changing Keymaps
Find the plugin in `plugins.lua` and modify the map call:
```lua
-- Example: Change database toggle key
map("n", "<leader>cdb", "<cmd>DBUIToggle<CR>")
-- Change to:
map("n", "<leader>db", "<cmd>DBUIToggle<CR>")
```

---

## Quick Start Guides

### AI Commit Messages
**Setup:** `export DEEPSEEK_API_KEY="your-api-key-here"` (add to ~/.zshrc)

**Usage:** `git add .` then `nvim` then `<Space>cg`

**In commit message tab:**
- `yyy` - Copy message
- `C` - Commit directly
- `d` - View API details
- `s` - Save to file
- `e` - Edit saved file
- `q` - Close tab

**Configure:** Edit `ai-commit.lua`

### Undo/Redo Tree
- `<Space>uf` - Floating undo preview (recommended): searchable, side-by-side diff preview
- `<Space>ut` - Side panel undo tree: tree structure, timestamps, diff preview
- `<Space>fu` - Search undo history via Telescope

In floating preview: `<CR>` yank additions, `<S-CR>` yank deletions, `<C-CR>` restore, `y`/`Y` yank, `u` restore.

In undo tree: `j/k` navigate, `<Enter>` restore, `q` close.

### Database Management
**Install clients:** `brew install postgresql mongosh mysql`

**Save connection:** `<Space>cdbs` -> enter name and URL

**Reconnect:** `<Space>cdbr` -> pick from Telescope

**Connection strings:**
```
PostgreSQL: postgresql://user:pass@localhost:5432/db
MongoDB:    mongodb://localhost:27017/db
MySQL:      mysql://user:pass@localhost:3306/db
SQLite:     sqlite:///path/to/db.db
```

Storage: `~/.config/nvim-general/db_ui_connections.json`

### URL Monitor
**Open:** `<Space>mp`

**Inside:** `a` add, `e` edit, `d` remove, `o` detail with latency chart, `r` refresh, `h` history, `q` close

Persists across sessions with history and latency charts.

### Snippets
**Browse:** `<Space>snp` (340+ snippets)

**Create:** visual select -> `<Space>snc` -> enter trigger name

**Available:**
- Dart/Flutter: ~100 snippets
- Lua: ~45 snippets
- JavaScript/React: ~30 snippets
- TypeScript: ~85 snippets
- Go: ~80 snippets

### Markdown Rendering
Auto-renders in `.md` files. Normal mode: rendered view. Insert mode: raw view.
Toggle with `<Space>mt`.

### Git Workflow
**Basic:** `<Space>gg` (Neogit), `<Space>ge` (Git Explorer), `<Space>gs` (stage), `<Space>gp` (push)

**View changes:** `<Space>gv` (Diffview), `]c`/`[c` (navigate), `<Space>hp` (preview), `<Space>hs` (stage)

**Undo changes:** visual select lines -> `<Space>hr` or `<Space>hu` -> reverts to HEAD. `u` to undo text revert. `<Space>hU` to restore from backup.

### File Navigation
**Find files:** `<Space>ff`, **Grep:** `<Space>fg`, **File tree:** `<Space>e`

In file tree: `<CR>` open, `o` open in new tab, `a` create, `d` delete, `r` rename.

---

## Troubleshooting

### General
- **Plugins not loading:** `:Lazy sync` then restart Neovim
- **Check health:** `:checkhealth`
- **See errors:** `:messages`

### Database
- **psql not found:** `brew install postgresql`
- **mongosh not found:** `brew install mongosh`
- **Connection refused:** `brew services list` then `brew services start <service>`

### LSP
- **Not working:** `:LspInfo` to check status, `:Mason` to install/update servers

### Snippets
- **Not showing:** `:set filetype?` to check filetype, `<Space>snd` for count, `<Space>snr` to reload

### Git
- **Neogit not opening:** `:Lazy sync`, verify `git --version` works

### Markdown
- **Not rendering:** `:TSInstall markdown`, `:Lazy sync`
- **Too slow:** Increase debounce in plugins.lua: `debounce = 200`

---

## Tips & Tricks

### Database
- Use env vars: `export DB_DEV="postgresql://localhost:5432/mydb"` then `$DB_DEV`
- Save read-only credentials for production
- Execute partial queries: visual select then `<CR>`
- Search saved connections: `<Space>cdbr` then type to filter

### Snippets
- Tab through placeholders after expansion
- Create project-specific snippets with `<Space>snc`
- Search in picker: `<Space>snp` then type trigger or description

### Git
- Quick stage: `<Space>gs` (interactive)
- Review changes: `<Space>gv` (Diffview), `]c`/`[c` navigate
- AI commit: `git add .` then `<Space>cg`

### File Navigation
- `<Space>ff` for name, `<Space>fa` for content (all), `<Space>fg` for content (.gitignore-aware)
- `<Space>fs` / `<Space>fd` for specific directory
- Browse undo: `<Space>uf` (floating) or `<Space>ut` (side panel)

### LSP
- `K` for documentation, `<Space>rn` for rename, `gr` for references

### Sessions
- Auto-save per git branch (already enabled)
- Manual: `<Space>ss` (save), `<Space>sr` (restore)

---

## Customization

### Change Colorscheme
In `plugins.lua`, find catppuccin config:
```lua
require("catppuccin").setup({
    flavour = "macchiato",  -- mocha, macchiato, frappe, latte
})
```

### Change Terminal Size
In `config.lua`:
```lua
vim.g.neoterm_size = '50'  -- Percentage of screen
```

### Add Custom Snippets
1. `<Space>snc` to create from selection
2. Or edit: `~/.config/nvim-general/snippets/<filetype>/custom.lua`

### Disable a Plugin
In `plugins.lua`, add `enabled = false`:
```lua
{
    "plugin-name",
    enabled = false,
}
```

---

## Resources

### Plugin Docs
- Telescope: https://github.com/nvim-telescope/telescope.nvim
- NvimTree: https://github.com/nvim-tree/nvim-tree.lua
- LSP: https://github.com/neovim/nvim-lspconfig
- Gitsigns: https://github.com/lewis6991/gitsigns.nvim
- Neogit: https://github.com/NeogitOrg/neogit
- vim-dadbod: https://github.com/tpope/vim-dadbod
- render-markdown: https://github.com/MeanderingProgrammer/render-markdown.nvim

### Neovim
- Docs: https://neovim.io/doc/
- Lua Guide: https://neovim.io/doc/user/lua-guide.html
