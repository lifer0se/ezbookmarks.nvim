-----------------------------
-- EzBookmarks by lifer0se --
-----------------------------

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local utils = require "ezbookmarks.utils"
local bookmark_file = vim.fn.stdpath('data') .. '/ezbookmarks.txt'
local ignore_file = vim.fn.stdpath('data') .. '/ezbookmarks.ign'

local cwd_on_open
local open_new_tab

local M = {}


M.setup = function(opts)
	cwd_on_open = opts.cwd_on_open
	open_new_tab = opts.open_new_tab
end


M.AddBookmark = function()
	local path = utils.get_path("Add to bookmark list")
	if path == nil then
		return
	end

	local ignore_list = utils.get_safe_list_from_file(ignore_file)
	local ignore_exists = utils.path_exists_in_list(path, ignore_list)
	if ignore_exists == 1 then
		local response = utils.get_user_response("Path \"" .. path .. "\" exists in the ignore list. Remove it? [y/N] ",
			"")
		if response:lower() == "y" or response:lower() == "yes" then
			utils.remove_path_from_list(path, ignore_list, ignore_file)
			print("Removed \"" .. path .. "\" from ignore list.")
		end
		return
	end

	local bookmark_list = utils.get_safe_list_from_file(bookmark_file)
	local bookmark_exists = utils.path_exists_in_list(path, bookmark_list)
	if bookmark_exists == 1 then
		print("Path \"" .. path .. "\" already exists in the bookmark list.")
		return
	elseif bookmark_exists == -1 then
		print("Path \"" .. path .. "\" is nested in another directory in the bookmark list.")
		return
	end

	if vim.fn.isdirectory(path) then
		utils.try_remove_nested_from_list(path, bookmark_list, bookmark_file)
	end

	local f = io.open(bookmark_file, 'a+')
	f:write(path .. '\n')
	f:close()
	print("Added \"" .. path .. "\" to bookmarks.")
end


M.AddIgnore = function()
	local path = utils.get_path("Add to ignore list")
	if path == nil then
		return
	end

	local ignore_list = utils.get_safe_list_from_file(ignore_file)
	local ignore_exists = utils.path_exists_in_list(path, ignore_list)
	if ignore_exists == 1 then
		print("Path \"" .. path .. "\" already exists in the ignore list.")
		return
	elseif ignore_exists == -1 then
		print("Path \"" .. path .. "\" is nested in another directory in the ignore list.")
		return
	end

	local bookmark_list = utils.get_safe_list_from_file(bookmark_file)
	local bookmark_exists = utils.path_exists_in_list(path, bookmark_list)
	if bookmark_exists == 1 then
		local response = utils.get_user_response(
			"Path \"" .. path .. "\" exists in the bookmark list. Remove it? [y/N] ", "")
		if response:lower() == "y" or response:lower() == "yes" then
			utils.remove_path_from_list(path, bookmark_list, bookmark_file)
			utils.remove_path_from_list(path, ignore_list, ignore_file)
			print("Removed \"" .. path .. "\" from bookmark list.")
		end
		return
	elseif bookmark_exists == 0 then
		print("Path \"" .. path .. "\" is not a nested path in the bookmark list.")
		return
	end

	if vim.fn.isdirectory(path) then
		utils.try_remove_nested_from_list(path, ignore_list, ignore_file)
	end

	local f = io.open(ignore_file, 'a+')
	f:write(path .. '\n')
	f:close()
	print("Added \"" .. path .. "\" to ignore list.")
end


local function open_selection(path)
	if path == nil then
		return
	end

	if cwd_on_open == 1 then
		vim.cmd(':cd ' .. utils.get_path_from_file(path))
	end

	if open_new_tab == 1 then
		vim.cmd(':tabedit ' .. path)
	else
		vim.cmd(':edit ' .. path)
	end
end


M.OpenBookmark = function(opts)
	local list = utils.get_safe_list_from_file(bookmark_file)
	if #list == 0 then
		print('Bookmark list is empty.')
		return
	end

	local ignore_list = utils.get_safe_list_from_file(ignore_file)
	local selection = {}
	for _, path in pairs(list) do
		if vim.fn.filereadable(path) == 1 then
			if utils.path_exists_in_list(path, ignore_list) ~= 0 then
				goto continue
			end
			selection[#selection + 1] = utils.sub_home_path(path)
			goto continue
		end

		local nested
		if (vim.fn.has("win32") == 0) then
			nested = io.popen("find " .. path .. " -type f")
		else
			nested = io.popen("cd " .. path .. " && dir /s /b | findstr /m /c:.")
		end

		for n in nested:lines() do
			if utils.path_exists_in_list(n, ignore_list) ~= 0 then
				goto continue
			end
			if not string.find(string.sub(n, #path + 1, #n), ".git") then
				selection[#selection + 1] = utils.sub_home_path(n)
			end
		end

		::continue::
	end

	opts = opts or {}
	pickers.new(opts, {
		prompt_title = "Open a bookmark",
		finder = finders.new_table {
			results = selection
		},
		layout_config = {
			preview_width = 0.5,
		},
		sorter = conf.file_sorter(opts),
		previewer = conf.file_previewer(opts),
		attach_mappings = function(prompt_bufnr, _)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				open_selection(action_state.get_selected_entry()[1])
			end)
			return true
		end,
	}):find()
end


M.RemoveBookmark = function(opts)
	local bookmark_list = utils.get_safe_list_from_file(bookmark_file)
	if #bookmark_list == 0 then
		print('Bookmark list is empty.')
		return
	end

	local ignore_list = utils.get_safe_list_from_file(bookmark_file)
	opts = opts or {}
	pickers.new(opts, {
		prompt_title = "Remove a bookmark",
		finder = finders.new_table {
			results = bookmark_list,
		},
		layout_config = {
			preview_width = 0.5,
		},
		sorter = conf.file_sorter(opts),
		previewer = conf.file_previewer(opts),
		attach_mappings = function(prompt_bufnr, _)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()[1]
				utils.remove_path_from_list(selection, bookmark_list, bookmark_file)
				utils.remove_path_from_list(selection, ignore_list, ignore_file)
				print("Removed \"" .. selection .. "\" from bookmarks.")
			end)
			return true
		end,
	}):find()
end


M.RemoveIgnore = function(opts)
	local ignore_list = utils.get_safe_list_from_file(ignore_file)
	if #ignore_list == 0 then
		print('Ignore list is empty.')
		return
	end

	opts = opts or {}
	pickers.new(opts, {
		prompt_title = "Remove an ignore",
		finder = finders.new_table {
			results = ignore_list,
		},
		layout_config = {
			preview_width = 0.5,
		},
		sorter = conf.file_sorter(opts),
		previewer = conf.file_previewer(opts),
		attach_mappings = function(prompt_bufnr, _)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()[1]
				utils.remove_path_from_list(selection, ignore_list, ignore_file)
				print("Removed \"" .. selection .. "\" from ignore list.")
			end)
			return true
		end,
	}):find()
end


return M
