-----------------------------
-- EzBookmarks by lifer0se --
-----------------------------

local u = assert(io.popen("echo $HOME", 'r'))
local home_path = assert(u:read('*a')):gsub("\n", "")
u:close()

local M = {}

M.get_user_response = function(message, default)
	local response = vim.fn.input(message, default)
	vim.api.nvim_command('normal! :')
	return response
end

M.get_path = function(message)
	local path = M.get_user_response(message .. ": ", vim.fn.expand("%:p"))
	if path == nil or path:gsub("%s+", "") == "" then
		return
	end
	if vim.fn.isdirectory(path) == 0 and vim.fn.filereadable(path) == 0 then
		print("Path \"" .. path .. "\" does not exist.")
		return
	end
	return path
end

M.path_exists_in_list = function(path, list)
	for _, v in pairs(list) do
		if path == v or v:sub(#path + 1) == "/" then
			return 1
		elseif path:match(v) then
			return -1
		end
	end
	return 0
end

M.try_remove_nested_from_list = function(path, list, file)
	local n = ""
	local has_changes = false
	for _, v in pairs(list) do
		if not v:find(path) then
			n = n .. v .. '\n'
		else
			has_changes = true
		end
	end
	if has_changes then
		local f = io.open(file, 'w')
		f:write(n)
		f:close()
	end
end

M.remove_path_from_list = function(path, list, file)
	local n = ""
	for _, v in pairs(list) do
		if v ~= path then
			n = n .. v .. '\n'
		end
	end
	local f = io.open(file, 'w')
	f:write(n)
	f:close()
end

M.get_safe_list_from_file = function(file)
	local list = {}
	if vim.fn.filereadable(file) == 0 then
		return list
	end

	local has_changes = false
	for line in io.lines(file) do
		if vim.fn.filereadable(line) == 1 or vim.fn.isdirectory(line) == 1 then
			list[#list + 1] = line
		else
			has_changes = true
		end
	end

	if has_changes then
		local n = ""
		for _, v in pairs(list) do
			n = n .. v .. '\n'
		end
		local f = io.open(file, 'w')
		f:write(n)
		f:close()
	end

	return list
end


M.sub_home_path = function(file)
	if string.sub(file, 0, #home_path) == home_path then
		return "~" .. string.sub(file, #home_path + 1, #file)
	else
		return file
	end
end


M.get_path_from_file = function(file)
	if (vim.fn.has("win32") == 0) then
		return file:match("(.*/)")
	else
		return file:match("(.*\\)")
	end
end


return M
