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
local f = assert(io.popen("echo $HOME", 'r'))
local home_path = assert(f:read('*a')):gsub("\n","")
f:close()

local M = {}

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
    path = path .. '/'
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


local function open_function(selection)
  if selection ~= nil then
    vim.cmd(':edit ' .. utils.get_path_from_config(selection[1]))
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
      if string.sub(v, 0, #home_path) == home_path then
        n[#n + 1] = "~" .. string.sub(v, #home_path + 1, #v)
      else
        n[#n + 1] = v
      end
    elseif vim.fn.isdirectory(v) == 1 then
      local p = io.popen("find ".. v .." -type f")
      for f in p:lines() do
        local tmp = string.sub(f, #v + 1, #f)
        if not string.find(tmp, ".git") then
          if string.sub(f, 0, #home_path) == home_path then
            n[#n + 1] = "~" .. string.sub(f, #home_path + 1, #f)
          else
            n[#n + 1] = f
          end
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
        open_function(action_state.get_selected_entry())
      end)
      return true
    end,
  }):find()
end


local function remove_function (lines)
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
        remove_function(lines)
      end)
      return true
    end,
  }):find()
end


return M
