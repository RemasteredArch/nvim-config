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

-- cpp.lua: configuration for clangd

local paths = {}
local generator = {}
local project_root = require("project_root")

--- Find the project's CMake build file.
---
--- @return path
local function find_cmake_file()
    local current_file = vim.fn.expand("%")
    local files = { "CMakeLists.txt" }
    local case = "home"
    return project_root.find_project_root(current_file, files, case)
end

--- Builds the project.
---
--- If necessary, generates the build script using CMake.
local function cmake_build()
    paths.cmake_file = find_cmake_file()

    if paths.cmake_file == nil then
        vim.api.nvim_err_writeln("No CMake build file found!")
        return
    end

    vim.notify("CMake build file: " .. paths.cmake_file)

    paths.project_root = project_root.get_parent_directory(paths.cmake_file)
    paths.build_dir = paths.project_root .. "/build"
    paths.output_file_name = "*.out"
    paths.output = paths.build_dir .. "/" .. paths.output_file_name

    if vim.fn.isdirectory(paths.build_dir) == 0 then
        vim.notify("No build directory found! Creating " .. paths.build_dir)
        vim.fn.mkdir(paths.build_dir)
    end

    generator.name = "Ninja"      -- As it appears in the generators section of `cmake --help`
    generator.build_cmd = "ninja" -- As would be entered into the shell
    generator.build_script = "build.ninja"

    if project_root.directory_contains(paths.build_dir, { generator.build_script }) == nil then
        vim.notify(generator.name .. " build script not found! Building CMake config now")
        vim.api.nvim_command(string.format("!cd \"%s\"; cmake .. -G %s", paths.build_dir, generator.name)) -- Outputs to a message automatically
    else
        vim.notify(generator.name .. " build script found! Skipping CMake config build.")
    end

    vim.api.nvim_command(string.format("!cd \"%s\"; %s", paths.build_dir, generator.build_cmd))
end

--- Runs the output of `cmake_build()`.
---
--- If there is no output, it will trigger `cmake_build()`.
local function cmake_run()
    if paths.build_dir == nil or project_root.directory_contains(paths.build_dir, { paths.output }) == nil then
        vim.notify("No build detecting! Building...")
        cmake_build()
    end

    vim.api.nvim_command(string.format("split | term cd \"%s\"; ./%s", paths.build_dir, paths.output_file_name))
end

--- Get the first listed and available compiler.
---
--- Compilers are listed internally (in `compilers`) as they would be entered into a shell prompt.
--- Assumes that the compiler takes arguments like so: `<compiler> ExampleFile.cpp -o <output> <args>`.
---
--- @return string
local function get_compiler()
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

local compiler = get_compiler();
local output = "./a.out"

-- Compile and run file
vim.keymap.set("n", "<leader>r",
    string.format("<cmd>split | term %s %% -o %s; %s; rm %s<cr>", compiler, output, output, output))

-- Compile and run file with args
vim.keymap.set("n", "<leader>cr", function()
    local user_input = vim.fn.input("Args: ")
    vim.api.nvim_command(
        string.format("split | term %s %% -o %s; %s %s; rm %s", compiler, output, output, user_input, output))
end)

-- Compile and run file with args and compiler args
vim.keymap.set("n", "<leader>crr", function()
    local compiler_input = vim.fn.input("Compiler Args: ")
    local program_input = vim.fn.input("Program Args: ")
    vim.api.nvim_command(
        string.format("split | term %s %% -o %s %s; %s %s; rm %s", compiler, output, compiler_input, output,
            program_input,
            output))
end)


-- Build cmake config (only if necessary) and compile project
vim.keymap.set("n", "<leader>ccb", cmake_build)

--[[
-- Build cmake config (even if it exists)
vim.keymap.set("n", "<leader>ccfb", function()
end)

]]
-- Run compiled project (following <leader>cbb)
-- This doesn't actually need to be like this -- Ninja will detect no changes!
vim.keymap.set("n", "<leader>ccr", cmake_run)
