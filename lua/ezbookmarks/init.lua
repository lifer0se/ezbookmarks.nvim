-----------------------------
-- EzBookmarks by lifer0se --
-----------------------------

local config_file = vim.fn.stdpath('data') .. '/ezbookmarks.txt'
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local M = {}

local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

local function lines_from(file)
  local lines = {}
	if not file_exists(file) then
		return lines
	end
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

local function get_path_from_config(config)
	for token in string.gmatch(config, "[^%s]+") do
		return token
 end
end

M.AddBookmark = function()
	local current_path = vim.fn.expand("%:p")
	if current_path == " " or current_path == "" or current_path == nil then
		return
	end

	local f = io.open(config_file, 'a+')
	local lines = lines_from(config_file)
	for k, v in pairs(lines) do
		if string.match(v, current_path) then
			print("Bookmark already exists.")
			return
		end
	end
	f:write(current_path .. '\n')
	f:close()
	print("Added current buffer to bookmarks.")
end

M.OpenBookmark = function(opts)
	local lines = lines_from(config_file)
	if #lines == 0 then
		print('No bookmarks found! Use the function "AddBookmark" on an open buffer to add one.')
		return
	end

	local n = ""
	for k, v in pairs(lines) do
		if file_exists(v) then
			n = n .. v .. '\n'
		else
			table.remove(lines, tonumber(k))
		end
	end
	local f = io.open(config_file, 'w')
	f:write(n)
	f:close()

	pickers.new(opts, {
		prompt_title = "Open a bookmark",
		finder = finders.new_table {
			results = lines
		},
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if selection ~= nil then
					local path = selection[1]:match("(.*/)")
					vim.cmd(':cd ' .. path)
					vim.cmd(':edit ' .. get_path_from_config(selection[1]))
				end
			end)
			return true
		end,
	}):find()
end

M.RemoveBookmark = function(opts)
	local lines = lines_from(config_file)
	if #lines == 0 then
		print('No bookmarks found! Use the function "AddBookmark" on an open buffer to add one.')
		return
	end

	pickers.new(opts, {
		prompt_title = "Remove a bookmark",
		finder = finders.new_table {
			results = lines
		},
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if selection ~= nil then
					local n = ""
					for k, v in pairs(lines) do
						if v ~= selection[1] then
							n = n .. v .. '\n'
						end
					end
					local f = io.open(config_file, 'w')
					f:write(n)
					f:close()
					print("Removed current buffer from bookmarks.")
				end
			end)
			return true
		end,
	}):find()
end

return M
