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

-- `packages.lua`: package lists and related helper utilities

local module = {}

module.list = require("config.package_list")

--- Return all string values of a table, regardless of nesting.
---
--- Intended to retrieve all packages from `package_list.lua`, or any subtable of it.
---
--- @param package_table table
--- @return string[]
module.get_all_packages = function(package_table) -- this might not be necessary, see :h Iter
    local array = {}

    local function recurse_table(input_table)
        for _, v in pairs(input_table) do
            if type(v) == "string" then
                table.insert(array, v)
            elseif type(v) == "table" then
                recurse_table(v)
            end
        end
    end

    recurse_table(package_table)
    return array
end

module.install = {}

--- Installs all Mason packages.
module.install.mason = function()
    require("mason-tool-installer").setup({
        ensure_installed = module.get_all_packages(module.list.mason),
        run_on_start = false
    })

    vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted",
        callback = function(event)
            if #event.data == 0 then
                print("Mason: no packages need to be installed.")
            end
        end,
        once = true
    })

    vim.cmd.MasonToolsInstallSync() -- Install all packages in a blocking manner
end

--- Installs all Treesitter packages.
module.install.treesitter = function()
    local installed = false
    for _, parser in ipairs(module.list.treesitter) do
        if not pcall(vim.treesitter.language.inspect, parser) then
            vim.cmd("TSInstallSync! " .. parser)
            installed = true
            print("\n")
        end
    end

    if not installed then
        print("Treesitter: no parsers needed to be installed.")
    end
end

function module.setup()
    require("mason").setup()

    require("config.lint").setup(module.list.mason.linter)

    require("config.format").setup(module.list.mason.formatter)

    require("mason-tool-installer").setup({
        ensure_installed = module.get_all_packages(module.list.mason),
        run_on_start = true
    })

    vim.api.nvim_create_user_command(
        "MasonInstallAll",
        module.install.mason,
        { force = true }
    )

    vim.api.nvim_create_user_command(
        "TSInstallAll",
        module.install.treesitter,
        { force = true }
    )
end

return module
