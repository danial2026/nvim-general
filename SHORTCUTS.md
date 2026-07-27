# Shortcuts

Leader key: `<Space>`

## AI & Chat
| Keymap | Action |
| ------ | ------ |
| `<Space>dc` | Toggle DeepSeek Chat |
| `<Space>cg` | Generate AI commit message |

## File Navigation
| Keymap | Action |
| ------ | ------ |
| `<Space>e` | Toggle file explorer (NvimTree) |
| `<Space>o` | Open new tab with NvimTree |
| `<Space>n` | Focus NvimTree |
| `<Space>a` | Toggle Alpha dashboard |

## Search (Telescope)
| Keymap | Action |
| ------ | ------ |
| `<Space>ff` | Find files |
| `<Space>fg` | Grep text (respects .gitignore) |
| `<Space>fa` | Grep text (all files) |
| `<Space>fc` | Search keymaps/commands |
| `<Space>th` | Theme picker |
| `<Space>fu` | Search undo history |
| `<Space>fs` | Grep in subdirectory |
| `<Space>fd` | Find files in subdirectory |
| `<Space>fi` | Internet search (StackOverflow) |
| `<Space>fo` | Open URL |

## Undo/Redo
| Keymap | Action |
| ------ | ------ |
| `<Space>ut` | Toggle Undo Tree |
| `<Space>uf` | Undo history (floating preview) |
| `<Space>fu` | Search undo history (Telescope) |

## LSP
| Keymap | Action |
| ------ | ------ |
| `K` | Hover documentation |
| `gd` | Go to definition |
| `gp` | Peek definition |
| `gr` | Find references |
| `<Space>ca` | Code action |
| `<Space>rn` | Rename symbol |
| `<Space>lf` | Format file |

## Diagnostics
| Keymap | Action |
| ------ | ------ |
| `<Space>xx` | Toggle diagnostics (Trouble) |
| `<Space>xw` | Buffer diagnostics |
| `<Space>xd` | Error diagnostics only |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<Space>df` | Show diagnostic float |
| `<Space>dl` | Diagnostics to location list |

## Git
| Keymap | Action |
| ------ | ------ |
| `<Space>gg` | Open Neogit |
| `<Space>ge` | Git Explorer |
| `<Space>ga` | Git add current file |
| `<Space>gA` | Git add all |
| `<Space>gs` | Stage files (interactive) |
| `<Space>gu` | Unstage files (interactive) |
| `<Space>gL` | Git log graph |
| `<Space>gv` | Open Diffview |
| `<Space>gV` | Close Diffview |
| `<Space>gh` | File history (all) |
| `<Space>gf` | File history (current file) |
| `<Space>gl` | Git log (custom) |

## Diffview (inside diff view)
| Keymap | Action |
| ------ | ------ |
| `gd` | Discard hunk (saves backup) |
| `gD` | Discard file (saves backup) |
| `gS` | Stage hunk |
| `<Space>hu` (vis) | Revert selected lines |
| `<Space>hU` | Restore last reverted file |
| `]c` / `[c` | Next/previous hunk |
| `g<C-x>` | Cycle layouts |

File panel: `S` stage all, `U` unstage all, `-` toggle stage, `X` restore entry.

## Git Hunks (inline, VS Code-style)
| Keymap | Action |
| ------ | ------ |
| `]c` | Next hunk |
| `[c` | Previous hunk |
| `<Space>hs` | Stage hunk (norm) / stage selected lines (vis) |
| `<Space>hr` | Reset hunk (norm) / revert selected lines w/ backup (vis) |
| `<Space>hu` (vis) | Revert selected lines (w/ backup for redo) |
| `<Space>hu` (norm) | Undo stage hunk |
| `<Space>hU` | Redo: restore last reverted selection |
| `<Space>hS` | Stage buffer |
| `<Space>hR` | Reset buffer |
| `<Space>hp` | Preview hunk |
| `<Space>hb` | Blame line |
| `<Space>tb` | Toggle line blame |
| `<Space>hd` | Diff this |
| `<Space>hD` | Diff this ~ |
| `<Space>td` | Toggle deleted |

Undo/redo workflow: select lines in visual mode -> `<Space>hr` or `<Space>hu` -> reverts to HEAD. `u` to undo the text revert. `<Space>hU` to restore from backup.

## Database
| Keymap | Action |
| ------ | ------ |
| `<Space>cdb` | Toggle Database UI |
| `<Space>cdba` | Add connection |
| `<Space>cdbs` | Save connection |
| `<Space>cdbr` | Reconnect |
| `<Space>cdbL` | List saved connections |
| `<Space>cdbf` | Find buffer |
| `<Space>cdbn` | Rename buffer |
| `<Space>cdbi` | Last query info |

## Snippets
| Keymap | Action |
| ------ | ------ |
| `<Space>snp` | Snippet picker (Telescope) |
| `<Space>snc` | Create snippet from selection |
| `<Space>snr` | Reload snippets |
| `<Space>snd` | Debug snippet count |
| `<CR>` (insert) | Expand snippet |
| `Tab` | Next placeholder |
| `Shift-Tab` | Previous placeholder |

## Markdown
| Keymap | Action |
| ------ | ------ |
| `<Space>mt` | Toggle rendering |
| `<Space>me` | Enable rendering |
| `<Space>md` | Disable rendering |

## TODO Comments
| Keymap | Action |
| ------ | ------ |
| `]t` | Next TODO/FIXME comment |
| `[t` | Previous TODO/FIXME comment |
| `<Space>st` | Search TODO/FIXME/NOTE/etc keywords |
| `<Space>sc` | Search ALL comment lines (filetype-aware) |
| `<Space>sC` | Broad comment search (regex) |

Keywords: TODO, FIXME, BUG, HACK, WARNING, NOTE, INFO, PERF, TEST, and more.

## Terminal
| Keymap | Action |
| ------ | ------ |
| `<Space>tt` | Toggle terminal |
| `<C-h/j/k/l>` (term) | Navigate splits |

## Sessions
| Keymap | Action |
| ------ | ------ |
| `<Space>ss` | Save session |
| `<Space>sr` | Restore session |
| `<Space>sd` | Delete session |
| `<Space>sf` | Search sessions |

## Comments
| Keymap | Action |
| ------ | ------ |
| `gCc` | Toggle line comment |
| `gCb` | Toggle block comment |
| `gc` | Comment operator |
| `gB` | Block comment operator |

## UI
| Keymap | Action |
| ------ | ------ |
| `<Space>it` | Toggle Incline (floating statusline) |
| `<Space>uT` | Toggle transparent background |
| `<Space>ttw` | Toggle Twilight |
| `<Space>tth` | Enable Twilight |
| `<Space>ttl` | Disable Twilight |

## URL Monitor
| Keymap | Action |
| ------ | ------ |
| `<Space>mp` | Open URL ping monitor |

## Clipboard
| Keymap | Action |
| ------ | ------ |
| `y` | Yank to system clipboard |
| `yy` | Yank line to system clipboard |
| `<Space>cp` | Copy file path to clipboard |
