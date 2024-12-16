--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along
with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

-- `files.lua`: various utilities for filesystem operations.

local module = {}

--- @alias path string A Unix-style file or directory path.

--- Get the parent directory of a given path.
---
--- # Examples:
---
--- - `path/to/file.ext` -> `path/to`
--- - `path/to/dir` -> `path/to`
---
--- @param path path
--- @return path
function module.get_parent_directory(path)
    local physical = vim.fn.fnamemodify(path, ":p")
    physical = physical:gsub("/$", "") -- Strip leading "/"

    return vim.fn.fnamemodify(physical, ":h")
end

--- Returns the last element of a given path.
---
--- Examples:
---
--- `path/to/file.ext` -> `file.ext`
--- `path/to/dir` -> `dir`
---
--- @param path path
--- @return string
function module.get_basename(path)
    return vim.fn.fnamemodify(path, ":t")
end

--- Checks whether or not a directory contains any one of a list of files.
---
--- Returns the path of the first file in the array that matches.
---
--- @param directory path
--- @param files path[]
--- @return path?
function module.directory_contains(directory, files)
    for _, file in ipairs(files) do
        local detect_file = vim.fn.glob(directory .. "/" .. file)

        if string.len(detect_file) > 0 then
            return detect_file
        end
    end
end

return module
