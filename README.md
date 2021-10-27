# cmp-nvim-lsp-document-symbol

nvim-cmp source for textDocument/documentSymbol via nvim-lsp.

# Setup

```lua
require'cmp'.cmdline.setup('/', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp_document_symbol' }
  }, {
    { name = 'buffer' }
  })
})
```

