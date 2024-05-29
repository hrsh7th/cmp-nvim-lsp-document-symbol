# cmp-nvim-lsp-document-symbol

nvim-cmp source for textDocument/documentSymbol via nvim-lsp.

The purpose is the demonstration customize `/` search by nvim-cmp.

<video src="https://user-images.githubusercontent.com/629908/139110682-b88e5e1f-f46f-4663-b92e-28b0007f9e52.mp4" width="100%"></video>

# Setup

```lua
require'cmp'.setup.cmdline('/', {
  sources = cmp.config.sources({
    {
        name = 'nvim_lsp_document_symbol',
        -- Show a little bit more than default LSP types for specific file types
        option = {
            kinds_to_show = {
                cpp = {
                    "Module", "Namespace", "Object", "Class", "Interface", "Method", "Function",
                    "Constructor" -- new
                }
            },
        },
    }
  }, {
    { name = 'buffer' }
  })
})
```

