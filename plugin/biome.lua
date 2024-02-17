local biome_cmds = vim.api.nvim_create_augroup("biome_cmds", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = biome_cmds,
	pattern = { "*.json", "*.jsonc", "*.js", "*.ts", "*.tsx" },
	desc = "Format on write",
	callback = function()
		vim.lsp.buf.format()
	end
})
