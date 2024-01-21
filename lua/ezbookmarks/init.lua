-----------------------------
-- EzBookmarks by lifer0se --
-----------------------------

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local previewers = require "telescope.previewers"
local make_entry = require "telescope.make_entry"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local utils = require "ezbookmarks.utils"
local bookmark_file = vim.fn.stdpath('data') .. '/ezbookmarks.txt'

local cwd_on_open
local use_bookmark_dir
local open_new_tab

local M = {}


M.setup = function (opts)
  cwd_on_open = opts.cwd_on_open
  use_bookmark_dir = opts.use_bookmark_dir
  open_new_tab = opts.open_new_tab
end


M.AddBookmark = function()
  local path = vim.fn.expand("%:p")
  if path == " " or path == "" or path == nil then
    return
  end
  if vim.fn.filereadable(path) == 0 then
    return
  end

  local b = utils.bookmark_exists(path)
  if b == 1 then
    print("File \"" .. path .. "\" already exists in the bookmark list.")
    return
  elseif b == -1 then
    print("File \"" .. path .. "\" is nested in a bookmark directory.")
    return
  end

  local f = io.open(bookmark_file, 'a+')
  f:write(path .. '\n')
  f:close()
  print("Added file \"" .. path .. "\" to bookmarks.")
end


M.AddBookmarkDirectory = function ()
  local path = vim.fn.expand("%:p:h")
  path = vim.fn.input("Add directory: ", path)
  vim.api.nvim_command('normal! :')
  if vim.fn.isdirectory(path) == 0 then
    print("Directory \"" .. path .."\" does not exist.")
    return
  end
  if string.sub(path, #path) ~= '/' then
    if (vim.fn.has("win32") == 0) then
      path = path .. '/'
    else
      path = path .. '\\'
    end
  end

  local b = utils.bookmark_exists(path)
  if b == 1 then
    print("Directory \"" .. path .. "\" already exists in the bookmark list!")
    return
  elseif b == -1 then
    print("Directory \"" .. path .. "\" is nested in another bookmark directory.")
    return
  end

  local lines = utils.get_lines_from_bookmark_file()
  local n = ""
  local has_changes = false
  for k, v in pairs(lines) do
    if not string.find(v, path) then
      n = n .. v .. '\n'
    else
      has_changes = true
    end
  end
  if has_changes then
    local f = io.open(bookmark_file, 'w')
    f:write(n)
    f:close()
  end

  local f = io.open(bookmark_file, 'a+')
  f:write(path .. '\n')
  f:close()
  print("Added directory \"" .. path .. "\" to bookmarks.")
end


local function open(selection)
  if selection ~= nil then

    local dir_found = false
    if use_bookmark_dir == 1 then
      local lines = utils.get_lines_from_bookmark_file()
      for k, f in pairs(lines) do
        local path = utils.sub_home_path(f)
        if string.match(selection, path) then
          local b = false
          if (vim.fn.has("win32") == 0) then
            b = string.sub(path, -1) == "/"
          else
            b = string.sub(path, -1) == "\\"
          end

          if b then
            vim.cmd(':cd ' .. path)
            dir_found = true
            break
          end
        end
      end
    end

    if cwd_on_open == 1 then
      if dir_found == false then
        vim.cmd(':cd ' .. utils.get_path_from_file(selection))
      end
    end

    if open_new_tab == 1 then
      vim.cmd(':tabedit ' .. selection)
    else
      vim.cmd(':edit ' .. selection)
    end
  end
end

M.OpenBookmark = function(opts)
  local lines = utils.get_lines_from_bookmark_file()
  if #lines == 0 then
    print('Bookmark list is empty.')
    return
  end

  local n = {}
  for k, v in pairs(lines) do
    if vim.fn.filereadable(v) == 1 then
      n[#n + 1] = utils.sub_home_path(v)
    elseif vim.fn.isdirectory(v) == 1 then
      local p = ""
      if (vim.fn.has("win32") == 0) then
        p = io.popen("find ".. v .." -type f")
      else
        -- The double quotes are im important. Without it, the
        -- dir command does not work with paths that contain
        -- forward slashes like D:/my-data
        p = io.popen('dir "' .. v .. '" /s /b /a-d')
      end
      for f in p:lines() do
        local tmp = string.sub(f, #v + 1, #f)
        if not string.find(tmp, ".git") then
          n[#n + 1] = utils.sub_home_path(f)
        end
      end
    end
  end
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Open a bookmark",
    finder = finders.new_table {
      results = n
    },
    layout_config = {
      preview_width = 0.5,
    },
    sorter = conf.file_sorter(opts),
    previewer = conf.file_previewer(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        open(action_state.get_selected_entry()[1])
      end)
      return true
    end,
  }):find()
end


local function remove (lines)
  local selection = action_state.get_selected_entry()
  if selection ~= nil then
    local n = ""
    for k, v in pairs(lines) do
      if v ~= selection[1] then
        n = n .. v .. '\n'
      end
    end
    local f = io.open(bookmark_file, 'w')
    f:write(n)
    f:close()
    print("Removed \"" .. selection[1] .. "\" from bookmarks.")
  end
end

M.RemoveBookmark = function(opts)
  local lines = utils.get_lines_from_bookmark_file()
  if #lines == 0 then
    print('Bookmark list is empty.')
    return
  end

  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Remove a bookmark",
    finder = finders.new_table {
      results = lines,
    },
    layout_config = {
      preview_width = 0.5,
    },
    sorter = conf.file_sorter(opts),
    previewer = conf.file_previewer(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        remove(lines)
      end)
      return true
    end,
  }):find()
end


return M
