-----------------------------
-- EzBookmarks by lifer0se --
-----------------------------

local bookmark_file = vim.fn.stdpath('data') .. '/ezbookmarks.txt'
local u = assert(io.popen("echo $HOME", 'r'))
local home_path = assert(u:read('*a')):gsub("\n","")
u:close()

local M = {}

M.get_lines_from_bookmark_file = function ()
  local lines = {}
  if vim.fn.filereadable(bookmark_file) == 0 then
    return lines
  end

  local has_changes = false
  for line in io.lines(bookmark_file) do
    if vim.fn.filereadable(line) == 1 or vim.fn.isdirectory(line) == 1 then
      lines[#lines + 1] = line
    else
      has_changes = true
    end
  end

  if has_changes then
    local n = ""
    for k, v in pairs(lines) do
      n = n .. v .. '\n'
    end
    local f = io.open(bookmark_file, 'w')
    f:write(n)
    f:close()
  end

  return lines
end


M.bookmark_exists = function (path)
  local lines = M.get_lines_from_bookmark_file()
  for k, v in pairs(lines) do
    if (vim.fn.filereadable(v) == 1 or vim.fn.isdirectory(v) == 1) and v == path then
      return 1
    elseif vim.fn.filereadable(v) == 1 then
      for k, v in pairs(lines) do
        if string.sub(v, #v) == "/" and string.match(path, v) and v ~= path then
          return -1
        end
      end
    elseif vim.fn.isdirectory(v) == 1 and string.match(path, v) then
      return -1
    end
  end
  return 0
end

M.sub_home_path = function (file)
  if string.sub(file, 0, #home_path) == home_path then
    return "~" .. string.sub(file, #home_path + 1, #file)
  end
end

M.get_path_from_file = function (file)
  return file:match("(.*/)")
end

return M
