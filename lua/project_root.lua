--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

-- project_root.lua: find the search parent directories until one contains any of a list of files or you hit an end case

local module = {}

-- e.g. path/to/file.ext -> path/to
-- or path/to/dir -> path/to
local function get_parent_directory(path)
  local physical = vim.fn.fnamemodify(path, ":p")
  physical = physical:gsub("/$", "") -- strip leading "/"

  return vim.fn.fnamemodify(physical, ":h")
end

-- e.g. path/to/file.ext -> file.ext
-- or path/to/dir -> dir
local function get_file_or_dir_name(path)
  return vim.fn.fnamemodify(path, ":t")
end

local function directory_contains(directory, files)
  for _, file in ipairs(files) do
    local detect_file = vim.fn.glob(directory .. "/" .. file)

    if string.len(detect_file) > 0 then
      return detect_file
    end
  end
end

function module.find_project_root(path, files, case)
  local directory = get_parent_directory(path)
  local case_type = type(case)

  if case_type == "string" then -- search parent directories up to case (e.g. home)
    local current_dir = directory

    while get_file_or_dir_name(current_dir) ~= case do
      local result = directory_contains(current_dir, files)

      if result ~= nil then
        return result
      end

      current_dir = get_parent_directory(current_dir)

      if current_dir == "/" then
        break
      end
    end
  elseif case_type == "number" then -- check only case number of parent directories
    local current_dir = directory

    while case > 0 do
      local result = directory_contains(current_dir, files)

      if result ~= nil then
        return result
      end


      current_dir = get_parent_directory(current_dir)
      case = case - 1

      if current_dir == "/" then
        case = 0
      end
    end
  else
    error("Invalid type for case: " .. case_type .. " (expects number or string)")
  end
end

return module
