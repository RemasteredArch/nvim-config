local html_lsp_cmds = vim.api.nvim_create_augroup("html_lsp_cmds", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = html_lsp_cmds,
  pattern = "*.html",
  desc = "Format on write",
  callback = function()
    vim.lsp.buf.format()
  end
})
