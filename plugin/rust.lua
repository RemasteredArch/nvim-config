local rust_analyzer_cmds = vim.api.nvim_create_augroup("rust_analyzer_cmds", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = rust_analyzer_cmds,
	pattern = "*.rs",
	desc = "Format on write",
	callback = function()
		vim.lsp.buf.format()
	end
})
