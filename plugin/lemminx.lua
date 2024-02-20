local lemminx_cmds = vim.api.nvim_create_augroup("lemminx_cmds", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = lemminx_cmds,
	pattern = "*.xml",
	desc = "Format on write",
	callback = function()
		vim.lsp.buf.format()
	end
})
