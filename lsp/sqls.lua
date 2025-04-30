--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2025 RemasteredArch

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

--- @class (exact) config.lsp.sqls.Connection A database connection. `dataSourceName` takes precedent over all following fields.
--- @field alias? string Pretty name
--- @field driver "mysql"|"postgresql"|"sqlite3"|"mssql"|"h2"
--- @field sshConfig? table<string, any>
--- @field dataSourceName? string
--- @field proto? "tcp"|"udp"|"unix"
--- @field passwd? string
--- @field host? string
--- @field port? string
--- @field path? string Unix socket path
--- @field dbName? string Database name
--- @field params? table<string, string> Option paramters

vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Register sqls configurations",
    group = vim.api.nvim_create_augroup("sqls_config", { clear = true }),
    callback = function(event)
        require("config.keymap").sqls().setup(event.buf)
    end
})

--- Build a connection string with the providered parameters.
---
--- E.g., `parameters = { server = "localhost", ["user id"] = "arch" }` returns
--- `"server=localhost;user id=arch;"`.
---
--- @param parameters table<string, string> The parameters of the connection string
--- @return string
local function mssql_connection(parameters)
    parameters = parameters or {}

    local connection_string = ""
    for key, value in pairs(parameters) do
        connection_string = ("%s%s=%s;"):format(connection_string, key, value)
    end

    return connection_string
end

--- @type config.lsp.sqls.Connection
local sql_express = {
    driver = "mssql",
    dataSourceName =
        mssql_connection({
            server = "localhost",
            port = "1433",
            ["user id"] = "arch",
            -- There has *got* to be a better way to do this than plain text in a
            -- config file!
            --
            -- Perhaps this _entire_ connection list should be an untracked file? I
            -- initially wanted to keep it (at least partly) here for reference,
            -- but I think that throwing it into the README instead could work.
            password = "the password in plain text",
            database = "master",
            encrypt = "true",
            TrustServerCertificate = "true"
        })
}

--- @type vim.lsp.Config
return {
    root_markers = {
        ".git",
        ".sqruff"
    },
    settings = {
        sqls = {
            --- @type config.lsp.sqls.Connection[]
            connections = {
                sql_express
            }
        }
    }
}
