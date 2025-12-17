# Neovim General Configuration

Complete reference for all plugins, configs, and keybindings in nvim-general.

---

## 🎯 Overview

This is a general-purpose Neovim configuration with:
- AI-powered commit messages
- 340+ language snippets
- Database management (PostgreSQL, MongoDB, MySQL, SQLite)
- Undo/Redo tree with visual browser and search
- Live markdown rendering
- LSP support
- Git integration
- File explorer
- Terminal management
- Session management
- And much more...

---

## 📦 All Installed Plugins

### Code Completion & LSP
- **nvim-cmp** - Completion engine
- **cmp-nvim-lsp** - LSP source for nvim-cmp
- **cmp-buffer** - Buffer completions
- **cmp-path** - Path completions
- **lspsaga.nvim** - Better LSP UI (hover, definition, rename, etc.)
- **trouble.nvim** - Diagnostics viewer

### Snippets
- **LuaSnip** - Snippet engine
- **friendly-snippets** - Collection of snippets
- **Custom snippets** - 340+ custom snippets (Dart, Lua, JS, TS, Go)

### File Navigation & Search
- **telescope.nvim** - Fuzzy finder (files, text, commands)
- **telescope-undo.nvim** - Search and browse undo history
- **Theme Picker** - Live theme browser & preview (live on selection move; Enter applies & persists selection; Esc restores previous theme)
- **nvim-tree.lua** - File explorer
- **which-key.nvim** - Keybinding helper

### Git Integration
- **gitsigns.nvim** - Git signs in gutter, hunk navigation
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
- **AI Commit Generator** - Generate commit messages with DeepSeek AI
- **DeepSeek Chat** - Chat with AI in Neovim

### Utilities
- **nui.nvim** - UI component library
- **plenary.nvim** - Lua utilities
- **undotree** - Visual undo tree browser

---

## ⌨️ All Keybindings

**Leader key:** `<Space>`

### AI & Chat
| Keymap      | Action                     |
| ----------- | -------------------------- |
| `<Space>dc` | Toggle DeepSeek Chat       |
| `<Space>cg` | Generate AI commit message |

### File Navigation
| Keymap     | Action                          |
| ---------- | ------------------------------- |
| `<Space>e` | Toggle file explorer (NvimTree) |
| `<Space>o` | Open new tab with NvimTree      |
| `<Space>a` | Toggle Alpha dashboard          |

### Search (Telescope)
| Keymap      | Action                                                                                     |
| ----------- | ------------------------------------------------------------------------------------------ |
| `<Space>ff` | Find files in current directory                                                            |
| `<Space>fg` | Grep text (respects .gitignore)                                                            |
| `<Space>fa` | Grep text in all files                                                                     |
| `<Space>fc` | Search all keymaps/commands                                                                |
| `<Space>th` | Theme picker (live preview on selection move; Enter=apply & persist, Esc=cancel & restore) |

| `<Space>fu` | Search undo history (with preview) |
| `<Space>fs` | Grep text in specific subdirectory |
| `<Space>fd` | Find files in specific subdirectory |
| `<Space>fi` | Internet search (StackOverflow via lynx) |
| `<Space>fo` | Open URL in lynx browser |

### Undo/Redo
| Keymap      | Action                          |
| ----------- | ------------------------------- |
| `<Space>u`  | Toggle Undo Tree (side panel)   |
| `<Space>uf` | Undo history (floating preview) |
| `<Space>fu` | Search undo history (Telescope) |

### LSP
| Keymap      | Action              |
| ----------- | ------------------- |
| `K`         | Hover documentation |
| `gd`        | Go to definition    |
| `gp`        | Peek definition     |
| `gr`        | Find references     |
| `<Space>ca` | Code action         |
| `<Space>rn` | Rename symbol       |
| `<Space>lf` | Format file         |

### Diagnostics
| Keymap      | Action                           |
| ----------- | -------------------------------- |
| `<Space>xx` | Toggle diagnostics (Trouble)     |
| `<Space>xw` | Diagnostics for current buffer   |
| `<Space>xd` | Error diagnostics only           |
| `[d`        | Previous diagnostic              |
| `]d`        | Next diagnostic                  |
| `<Space>df` | Show diagnostic in float         |
| `<Space>dl` | Add diagnostics to location list |

### Git
| Keymap      | Action                          |
| ----------- | ------------------------------- |
| `<Space>gg` | Open Neogit                     |
| `<Space>gc` | Git commit                      |
| `<Space>gp` | Git push                        |
| `<Space>gP` | Git pull                        |
| `<Space>ga` | Git add current file            |
| `<Space>gA` | Git add all files               |
| `<Space>gs` | Git stage (interactive)         |
| `<Space>gu` | Git unstage (interactive)       |
| `<Space>gL` | Git log graph                   |
| `<Space>gv` | Open Diffview                   |
| `<Space>gV` | Close Diffview                  |
| `<Space>gh` | Git file history (all)          |
| `<Space>gf` | Git file history (current file) |
| `<Space>gl` | Git log (custom)                |

### Git Hunks
| Keymap      | Action            |
| ----------- | ----------------- |
| `]c`        | Next hunk         |
| `[c`        | Previous hunk     |
| `<Space>hs` | Stage hunk        |
| `<Space>hr` | Reset hunk        |
| `<Space>hS` | Stage buffer      |
| `<Space>hu` | Undo stage hunk   |
| `<Space>hR` | Reset buffer      |
| `<Space>hp` | Preview hunk      |
| `<Space>hb` | Blame line        |
| `<Space>tb` | Toggle line blame |
| `<Space>hd` | Diff this         |
| `<Space>hD` | Diff this ~       |
| `<Space>td` | Toggle deleted    |

### Database
| Keymap        | Action                        |
| ------------- | ----------------------------- |
| `<Space>cdb`  | Toggle Database UI            |
| `<Space>cdba` | Add connection to DBUI        |
| `<Space>cdbs` | Save connection (with name)   |
| `<Space>cdbr` | Reconnect (select from saved) |
| `<Space>cdbL` | List all saved connections    |
| `<Space>cdbf` | Find buffer                   |
| `<Space>cdbn` | Rename buffer                 |
| `<Space>cdbi` | Last query info               |

### Snippets
| Keymap          | Action                      |
| --------------- | --------------------------- |
| `<Space>snp`    | Snippet picker (Telescope)  |
| `<Space>snc`    | Create custom snippet       |
| `<Space>snr`    | Reload all snippets         |
| `<Space>snd`    | Debug snippets (show count) |
| `<CR>` (insert) | Expand snippet              |
| `Tab`           | Next placeholder            |
| `Shift-Tab`     | Previous placeholder        |

### Markdown
| Keymap      | Action            |
| ----------- | ----------------- |
| `<Space>mt` | Toggle rendering  |
| `<Space>me` | Enable rendering  |
| `<Space>md` | Disable rendering |

### Terminal
| Keymap             | Action               |
| ------------------ | -------------------- |
| `<Space>tt`        | Toggle terminal      |
| `<C-h>` (terminal) | Move to left split   |
| `<C-j>` (terminal) | Move to bottom split |
| `<C-k>` (terminal) | Move to top split    |
| `<C-l>` (terminal) | Move to right split  |

### Sessions
| Keymap      | Action          |
| ----------- | --------------- |
| `<Space>ss` | Save session    |
| `<Space>sr` | Restore session |
| `<Space>sd` | Delete session  |
| `<Space>sf` | Search sessions |

### Comments
| Keymap | Action                     |
| ------ | -------------------------- |
| `gCc`  | Toggle line comment        |
| `gCb`  | Toggle block comment       |
| `gc`   | Comment operator/selection |
| `gB`   | Block comment operator     |

### UI
| Keymap       | Action                               |
| ------------ | ------------------------------------ |
| `<Space>it`  | Toggle Incline (floating statusline) |
| `<Space>ttw` | Toggle Twilight                      |
| `<Space>tth` | Enable Twilight                      |
| `<Space>ttl` | Disable Twilight                     |

### Clipboard
| Keymap      | Action                        |
| ----------- | ----------------------------- |
| `y`         | Yank to system clipboard      |
| `yy`        | Yank line to system clipboard |
| `<Space>cp` | Copy file path to clipboard   |

---

## 🚀 Quick Start Guides

### AI Commit Messages

**Setup:**
```bash
export DEEPSEEK_API_KEY="your-api-key-here"
# Add to ~/.zshrc or ~/.bashrc to make permanent
```

**Usage:**
```bash
git add .
nvim
<Space>cg  # Generate commit
```

Press `a` to accept, `e` to edit, `q` to close.

**Configuration:** Edit `ai-commit.lua` to customize model, temperature, prompt templates.

### Undo/Redo Tree

**Floating Undo Preview (Recommended):**
```
<Space>uf  # Open undo history in floating window
```

Large centered floating window with:
- Search through undo history
- Side-by-side preview of changes
- 95% screen coverage for maximum visibility
- All Telescope undo features

**Side Panel Undo Tree:**
```
<Space>u   # Toggle visual undo tree (side panel)
```

Traditional tree view shows:
- Complete undo history as a tree structure
- Time stamps for each change
- Diff preview of changes
- Navigate with `j/k`, restore with `<Enter>`

**Search Undo History:**
```
<Space>fu  # Search through undo history (standard layout)
```

Features:
- **Search changes:** Type to filter by actual code changes
- **Preview diffs:** See what changed at each state
- **Quick restore:** Press `<C-CR>` to restore to that state
- **Yank changes:** Press `<CR>` to yank additions, `<S-CR>` for deletions

**Common workflow:**
```
1. Make changes, realize you need something from 10 edits ago
2. <Space>uf  # Open floating undo preview (recommended)
3. Search for the code you remember
4. Press y to yank it, or <C-CR> to restore to that point
```

**In Floating Undo Preview (`<Space>uf`):**
- Large centered window (95% screen)
- Type to search through changes
- `<CR>` - Yank additions
- `<S-CR>` - Yank deletions  
- `<C-CR>` - Restore to that state
- `y/Y` - Yank additions/deletions (normal mode)
- `u` - Restore (normal mode)

**In Undo Tree (`<Space>u`):**
- `j/k` - Navigate through history
- `<Enter>` - Restore to selected state
- `q` - Close undo tree

### Database Management

**Install clients:**
```bash
brew install postgresql  # PostgreSQL
brew install mongosh     # MongoDB
brew install mysql       # MySQL (optional)
```

**Save a connection:**
```
<Space>cdbs
Name: Dev Postgres
URL:  postgresql://user:password@localhost:5432/mydb
```

**Reconnect:**
```
<Space>cdbr  # Opens Telescope picker with saved connections
```

**Connection strings:**
```
PostgreSQL: postgresql://user:pass@localhost:5432/db
MongoDB:    mongodb://localhost:27017/db
MySQL:      mysql://user:pass@localhost:3306/db
SQLite:     sqlite:///path/to/db.db
```

**Storage:** `~/.config/nvim-general/db_ui_connections.json`

### Snippets

**Browse all snippets:**
```
<Space>snp  # Telescope picker with 340+ snippets
```

**Create custom snippet:**
```
1. Visual select code
2. <Space>snc
3. Enter trigger name
```

**Available:**
- Dart/Flutter: ~100 snippets (`stless`, `stful`, `scaffold`, etc.)
- Lua: ~45 snippets (`func`, `keymap`, `autocmd`, etc.)
- JavaScript/React: ~30 snippets (`rfc`, `useState`, etc.)
- TypeScript: ~85 snippets (`interface`, `type`, etc.)
- Go: ~80 snippets (`func`, `struct`, etc.)

### Markdown Rendering

**Auto-renders in `.md` files:**
- Normal mode: See rendered markdown
- Insert mode: See raw markdown

**Toggle:** `<Space>mt`

### Git Workflow

**Basic workflow:**
```
<Space>gg   # Open Neogit
<Space>gs   # Stage files interactively
<Space>gc   # Commit
<Space>gp   # Push
```

**View changes:**
```
<Space>gv   # Open Diffview
]c / [c     # Navigate hunks
<Space>hp   # Preview hunk
<Space>hs   # Stage hunk
```

### File Navigation

**Find files:**
```
<Space>ff   # Find files
<Space>fg   # Grep text
<Space>e    # Toggle file tree
```

**In file tree:**
- `<CR>` - Open file
- `o` - Open in new tab with tree
- `a` - Create file
- `d` - Delete file
- `r` - Rename file

---

## ⚙️ Configuration

### File Locations

```
~/.config/nvim-general/
├── config.lua              # General settings, keymaps
├── plugins.lua             # All plugin configurations
├── ai-commit.lua           # AI commit generator
├── commit-rules.lua        # Commit message rules
├── db_ui_connections.json  # Saved database connections
├── README.md               # This file
└── snippets/               # Custom snippets
    ├── dart/
    ├── lua/
    ├── javascript/
    ├── typescript/
    └── go/
```

### Main Settings (config.lua)

**Leader key:** Space (already set)

**General settings:**
```lua
vim.opt.number = true          -- Line numbers
vim.opt.signcolumn = "yes"     -- Always show sign column
vim.opt.tabstop = 2            -- Tab size
vim.opt.shiftwidth = 2         -- Indent size
vim.opt.expandtab = true       -- Use spaces instead of tabs
vim.opt.termguicolors = true   -- True color support
vim.opt.cursorline = true      -- Highlight current line
```

**Change in config.lua to customize.**

### Plugin Settings (plugins.lua)

**Database UI:**
```lua
vim.g.db_ui_win_position = "right"  -- "left" or "right"
vim.g.db_ui_winwidth = 40           -- Width
vim.g.db_ui_use_nerd_fonts = 1      -- Use icons
```

**Markdown rendering:**
```lua
require("render-markdown").setup({
    enabled = true,                      -- Auto-enable
    heading = {
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    },
    code = {
        border = "thin",                 -- "thin" or "thick"
    },
    bullet = {
        icons = { "●", "○", "◆", "◇" },
    },
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
    view = { width = 35, side = "left" },  -- Change width/side
    filters = { dotfiles = false },        -- Show hidden files
})
```

### Change Keymaps

Find the plugin in `plugins.lua` and modify:

```lua
-- Example: Change database toggle key
map("n", "<leader>cdb", "<cmd>DBUIToggle<CR>")
-- Change to:
map("n", "<leader>db", "<cmd>DBUIToggle<CR>")
```

---

## 🐛 Troubleshooting

### General Issues

**Plugins not loading:**
```vim
:Lazy sync
" Restart Neovim
```

**Check health:**
```vim
:checkhealth
```

**See error messages:**
```vim
:messages
```

### Database Issues

**"psql: command not found"**
```bash
brew install postgresql
```

**"mongosh: command not found"**
```bash
brew install mongosh
```

**Connection refused:**
```bash
brew services list
brew services start postgresql
brew services start mongodb-community
```

### LSP Issues

**LSP not working:**
```vim
:LspInfo  # Check LSP status
:Mason    # Install/update language servers
```

### Snippet Issues

**Snippets not showing:**
```vim
:set filetype?        # Check filetype
<Space>snd            # Show snippet count
<Space>snr            # Reload snippets
```

### Git Issues

**Neogit not opening:**
```vim
:Lazy sync
" Make sure git is installed: git --version
```

### Markdown Issues

**Not rendering:**
```vim
:TSInstall markdown
:Lazy sync
```

**Too slow:**
```lua
-- In plugins.lua, increase debounce
debounce = 200,  -- From 100 to 200
```



## 💡 Tips & Tricks

### Database

1. **Use environment variables:**
   ```bash
   export DB_DEV="postgresql://localhost:5432/mydb"
   # Then use $DB_DEV in connections
   ```



2. **Save read-only credentials for production:**
   ```
   postgresql://readonly:pass@prod:5432/db
   ```

3. **Execute partial queries:** Visual select query, press `<CR>`

4. **Search saved connections:** `<Space>cdbr` then type to filter

### Snippets

1. **Tab through placeholders:** After expanding, use Tab/Shift-Tab

2. **Create project-specific snippets:** `<Space>snc` for quick templates

3. **Search in picker:** `<Space>snp` then type trigger or description

### Git

1. **Quick stage and commit:**
   ```
   <Space>gs  # Interactive stage
   <Space>gc  # Commit
   ```

2. **Review changes before committing:**
   ```
   <Space>gv  # Diffview
   ]c / [c    # Navigate changes
   ```

3. **Use AI for commit messages:**
   ```
   git add .
   <Space>cg  # AI generates commit message
   ```

### File Navigation

1. **Quick file switching:**
   ```
   <Space>ff  # Find by name (all files)
   <Space>fa  # Find by content (all files)
   <Space>fg  # Find by content (respects .gitignore)
   ```

2. **Search in specific directory:**
   ```
   <Space>fs  # Grep in subdirectory
   <Space>fd  # Find files in subdirectory
   ```

3. **Gitignore-aware search:**
   ```
   <Space>fg  # Grep content only in files not in .gitignore
              # Useful for searching source code without build artifacts
   ```

4. **Browse undo history:**
   ```
   <Space>uf  # Floating undo preview (large centered window)
              # Find that code you deleted 20 changes ago
   <Space>u   # Side panel tree view (traditional layout)
   ```

### LSP

1. **Quick documentation:** Press `K` on any symbol

2. **Rename across project:** `<Space>rn` on symbol

3. **View all references:** `gr` on symbol

### Sessions

1. **Auto-save sessions:** Already enabled per git branch

2. **Manual session management:**
   ```
   <Space>ss  # Save
   <Space>sr  # Restore
   ```

---

## 🎨 Customization

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

```
1. <Space>snc to create from selection
2. Or edit: ~/.config/nvim-general/snippets/<filetype>/custom.lua
```

### Disable a Plugin

In `plugins.lua`, comment out or add `enabled = false`:

```lua
{
    "plugin-name",
    enabled = false,  -- Disable plugin
}
```

---

## 📚 Resources

### Plugin Documentation

- **Telescope:** https://github.com/nvim-telescope/telescope.nvim
- **NvimTree:** https://github.com/nvim-tree/nvim-tree.lua
- **LSP:** https://github.com/neovim/nvim-lspconfig
- **Gitsigns:** https://github.com/lewis6991/gitsigns.nvim
- **Neogit:** https://github.com/NeogitOrg/neogit
- **vim-dadbod:** https://github.com/tpope/vim-dadbod
- **render-markdown:** https://github.com/MeanderingProgrammer/render-markdown.nvim

### Neovim Resources

- **Neovim Docs:** https://neovim.io/doc/
- **Lua Guide:** https://neovim.io/doc/user/lua-guide.html

---

## ✅ Summary

**Features:**
- AI commit messages (DeepSeek API)
- 340+ snippets (5 languages)
- Database interface (4 database types)
- Live markdown rendering
- Full LSP support
- Complete Git integration
- File explorer and fuzzy finder
- Terminal management
- Session management
- Beautiful UI with Catppuccin theme

**Quick Start:**
```
<Space>ff   # Find files (all)
<Space>fa   # Search text (all files)
<Space>fg   # Search text (respects .gitignore)
<Space>uf   # Undo history (floating preview)
<Space>u    # Undo tree (side panel)
<Space>e    # File tree
<Space>cdb  # Database
<Space>snp  # Snippets
<Space>gg   # Git
<Space>cg   # AI commit
```

**Configuration:** `~/.config/nvim-general/`

**Everything documented. Ready to use!** 🚀
