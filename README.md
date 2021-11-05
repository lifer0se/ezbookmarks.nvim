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

#### To add a directory as a bookmark:

```lua
:lua require"ezbookmarks".AddBookmarkDirectory()
```
A bookmark directory will include all the files in that directory and it's sub-directories to the OpenBookmark list.

#### To remove a bookmark:

```lua
:lua require"ezbookmarks".RemoveBookmark()
```

#### To browse through your bookmarks:

```lua
:lua require"ezbookmarks".OpenBookmark()
```

## Options

```lua
require('ezbookmarks').setup{
  cwd_on_open = 1,        -- change directory when opening a bookmark
  use_bookmark_dir = 1,   -- if a bookmark is part of a bookmarked directory, cd to that direcrtory (works independently of cwd_on_open)
  open_new_tab = 1,       -- open bookmark in a new tab.
}
```
