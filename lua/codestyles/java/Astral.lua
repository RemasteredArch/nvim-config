-- Astral.lua: custom config to adhere to the code style of https://github.com/Jaxydog/Astral

local opt = vim.opt

-- spaces, not tabs
opt.shiftwidth = 4
opt.expandtab = true
opt.smarttab = true

opt.tabstop = 8     -- make it obvious when a tab char is used instead of spaces
opt.softtabstop = 0 -- redundant, but set just in case init.lua changes
