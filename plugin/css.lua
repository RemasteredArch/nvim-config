local css_lsp_cmds = vim.api.nvim_create_augroup("css_lsp_cmds", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = css_lsp_cmds,
  pattern = "*.css",
  desc = "Format on write",
  callback = function()
    vim.lsp.buf.format()
  end
})
