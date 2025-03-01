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

-- `cpp.lua`: configuration and utilities for C++ and clangd

local M = {}

local paths = {}
local generator = {}
local fs = require("util.files")

--- Find the project's CMake build file.
---
--- @return path?
local function find_cmake_file()
    local result = vim.fs.find("CMakeLists.txt", {
        upwards = true,
        stop = "home",
        type = "file",
        limit = 1
    })

    if not vim.tbl_isempty(result) then
        return result[1]
    end
end

--- Builds the project.
---
--- If necessary, generates the build script using CMake.
function M.cmake_build()
    paths.cmake_file = find_cmake_file()

    if paths.cmake_file == nil then
        vim.api.nvim_err_writeln("No CMake build file found!")
        return
    end

    vim.notify("CMake build file: " .. paths.cmake_file)

    paths.project_root = fs.get_parent_directory(paths.cmake_file)
    paths.build_dir = vim.fs.joinpath(paths.project_root, "build")
    paths.output_file_name = "*.out"
    paths.output = vim.fs.joinpath(paths.build_dir, paths.output_file_name)

    if vim.fn.isdirectory(paths.build_dir) == 0 then
        vim.notify("No build directory found! Creating " .. paths.build_dir)
        vim.fn.mkdir(paths.build_dir)
    end

    generator.name = "Ninja"      -- As it appears in the generators section of `cmake --help`.
    generator.build_cmd = "ninja" -- As would be entered into the shell.
    generator.build_script = "build.ninja"

    if fs.directory_contains(paths.build_dir, { generator.build_script }) == nil then
        vim.notify(generator.name .. " build script not found! Building CMake config now")
        vim.api.nvim_command(string.format("!cd \"%s\"; cmake .. -G %s", paths.build_dir,
            generator.name)) -- Outputs to a message automatically.
    else
        vim.notify(generator.name .. " build script found! Skipping CMake config build.")
    end

    vim.api.nvim_command(string.format("!cd \"%s\"; %s", paths.build_dir, generator.build_cmd))
end

--- Runs the output of `M.cmake_build()`.
---
--- If there is no output, it will trigger `M.cmake_build()`.
function M.cmake_run()
    if paths.build_dir == nil or fs.directory_contains(paths.build_dir, { paths.output }) == nil then
        vim.notify("No build detecting! Building...")
        M.cmake_build()
    end

    vim.api.nvim_command(string.format("split | term cd \"%s\"; ./%s", paths.build_dir,
        paths.output_file_name))
end

--- Get the first listed and available compiler.
---
--- Compilers are listed internally (in `compilers`) as they would be entered into a shell prompt.
--- Assumes that the compiler takes arguments like so: `<compiler> ExampleFile.cpp -o <output> <args>`.
---
--- @return string
function M.get_compiler()
    --- @type { preferred: string, other: string[] }
    local compilers = {
        preferred = "g++",
        other = { "clang++" }
    }

    if vim.fn.executable(compilers.preferred) == 1 then
        vim.notify("Using " .. compilers.preferred)
        return compilers.preferred
    end

    for _, compiler in ipairs(compilers.other) do
        if vim.fn.executable(compiler) == 1 then
            vim.notify("Using " .. compiler)
            return compiler
        end
    end

    error("No suitable C++ compiler found!", 1)
end

M.output = "./a.out"

return M
