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

-- `dap.lua`: configurations for DAP (debug adapter protocol)

local dap = require("dap")

local module = {}

function module.setup()
    -- C, C++, and Rust
    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = "codelldb",
            args = { "--port", "${port}" }
        }
    }

    dap.configurations.cpp = {
        {
            name = "Launch",
            type = "codelldb",
            request = "launch",
            program = "${workspaceFolder}/build/*.out", -- This is fragile!
            cwd = "${workspaceFolder}"
        }
    }

    dap.configurations.c = dap.configurations.cpp

    require("dapui").setup()
    require("config.keymap").dap().setup()
end

return module
