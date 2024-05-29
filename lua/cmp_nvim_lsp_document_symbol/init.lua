local source = {}

local SymbolKind = {
  [1] = "File",
  [2] = "Module",
  [3] = "Namespace",
  [4] = "Package",
  [5] = "Class",
  [6] = "Method",
  [7] = "Property",
  [8] = "Field",
  [9] = "Constructor",
  [10] = "Enum",
  [11] = "Interface",
  [12] = "Function",
  [13] = "Variable",
  [14] = "Constant",
  [15] = "String",
  [16] = "Number",
  [17] = "Boolean",
  [18] = "Array",
  [19] = "Object",
  [20] = "Key",
  [21] = "Null",
  [22] = "EnumMember",
  [23] = "Struct",
  [24] = "Event",
  [25] = "Operator",
  [26] = "TypeParameter",
}

local defaults = {
  kinds_to_show = { "Module", "Namespace", "Object", "Class", "Interface", "Method", "Function" },
}

source.new = function()
  return setmetatable({}, { __index = source })
end

source.is_available = function(self)
  return self:_get_client() ~= nil
end

source.get_keyword_pattern = function()
  return [=[@.*]=]
end

source.get_trigger_characters = function()
  return { "@" }
end

source._get_kinds_to_show = function(self, params)
  local ft = vim.bo.filetype
  if params.option.kinds_to_show then
    return params.option.kinds_to_show[ft] or defaults.kinds_to_show
  end
  return defaults.kinds_to_show
end

source.complete = function(self, params, callback)
  local client = self:_get_client()
  local option = vim.tbl_deep_extend("keep", params.option or {}, defaults)
  client.request(
    "textDocument/documentSymbol",
    { textDocument = vim.lsp.util.make_text_document_params() },
    function(err, res)
      if err then
        return callback()
      end

      local items = {}
      local traverse
      traverse = function(nodes, level, parent)
        level = level or 0
        parent = parent or ""
        for _, node in ipairs(nodes) do
          local kind_name = SymbolKind[node.kind]
          local kinds_to_show = self:_get_kinds_to_show(params)
          if vim.tbl_contains(kinds_to_show, kind_name) then
            -- node may be LSP DocumentSymbol or SymbolInformation (deprecated)
            local range = node.selectionRange or node.range or (node.location or {}).range
            if range ~= nil then
              local line = vim.api.nvim_buf_get_lines(0, range.start.line, range.start.line + 1, false)[1]
                  or ""
              table.insert(items, {
                label = ("%s%s"):format(string.rep(" ", level), string.gsub(line, "^%s*", "")),
                insertText = ("\\%%%sl"):format(range.start.line + 1),
                filterText = "@" .. node.name,
                sortText = "" .. range.start.line,
                kind = node.kind,
                data = node,
              })
              traverse(node.children or {}, level + 1)
              parent = parent .. "::" .. node.name
            end
          end
        end
      end
      traverse(res or {})
      callback(items)
    end,
    0
  )
end

source._get_client = function(self)
  for _, client in pairs(vim.lsp.buf_get_clients()) do
    if self:_get(client.server_capabilities, { "documentSymbolProvider" }) then
      return client
    end
  end
  return nil
end

source._get = function(_, root, paths)
  local c = root
  for _, path in ipairs(paths) do
    c = c[path]
    if not c then
      return nil
    end
  end
  return c
end

return source
