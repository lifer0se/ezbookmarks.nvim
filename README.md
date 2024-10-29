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
Bookmarks can be files or directories.


#### To add an file to the ignore list:

```lua
:lua require"ezbookmarks".AddIgnore()
```
Any nested file or directory of a bookmark can be ignored. It will not show on the bookmark list.


#### To remove a bookmark:

```lua
:lua require"ezbookmarks".RemoveBookmark()
```


#### To remove an ignore entry:

```lua
:lua require"ezbookmarks".RemoveIgnore()
```


#### To browse through your bookmarks:

```lua
:lua require"ezbookmarks".OpenBookmark()
```


## Options

```lua
require('ezbookmarks').setup{
  cwd_on_open = 1,        -- change directory when opening a bookmark
  open_new_tab = 1,       -- open bookmark in a new tab.
}
```

Running the setup function is not necessary, the plugin will work without it.

Let me know if there's any other options or features you'd like to see :)
