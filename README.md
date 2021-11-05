# EzBookmarks.nvim

#### A bookmark plugin.
Simply add your current buffer to the bookmark list, then browse through the list (requires telescope).
You can even bookmark a directory and have access to all files in that directory.

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
When removing a directory from bookmarks, only the directory will appear on the list, not all included files.

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

Running the setup function is not necessary, the plugin will work without it.

Let me know if there's any other options or features you'd like to see :)
