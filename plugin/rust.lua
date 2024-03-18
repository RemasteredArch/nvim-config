local rust_analyzer_cmds = vim.api.nvim_create_augroup("rust_analyzer_cmds", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = rust_analyzer_cmds,
	pattern = "*.rs",
	desc = "Format on write",
	callback = function()
		vim.lsp.buf.format()
	end
})

vim.keymap.set("n", "<leader>gl", "<cmd>lua vim.diagnostic.open_float()<cr>")
vim.keymap.set("n", "<leader>r", "<cmd>split | term cargo run<cr>")
vim.keymap.set("n", "<leader>cr", function()
	local user_input = vim.fn.input("Args: ")
	vim.api.nvim_command("split | term cargo run -- " .. user_input)
end)
