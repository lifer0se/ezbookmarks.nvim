# EzBookmarks.nvim

#### A bookmark plugin.
Simply add your current buffer to the bookmark list, then browse through the list (requires telescope).


## Installation
#### Requires neovim 0.5.0+

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'lifer0se/ezbookmarks.nvim'
```

## Commands
#### To add a bookmark:

```lua
:lua require"ezbookmarks".AddBookmark()
```

#### To remove a bookmark:

```lua
:lua require"ezbookmarks".RemoveBookmark()
```

#### To browse through your bookmarks:

```lua
:lua require"ezbookmarks".OpenBookmark()
```
