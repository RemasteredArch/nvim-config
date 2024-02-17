local lua_ls_cmds = vim.api.nvim_create_augroup("lua_ls_cmds", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = lua_ls_cmds,
	pattern = "*.lua",
	desc = "Format on write",
	callback = function()
		vim.lsp.buf.format()
	end
})
