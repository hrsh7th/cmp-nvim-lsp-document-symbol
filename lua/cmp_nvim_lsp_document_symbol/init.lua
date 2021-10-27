local source = {}

local SymbolKind = {
  [1] = 'File',
  [2] = 'Module',
  [3] = 'Namespace',
  [4] = 'Package',
  [5] = 'Class',
  [6] = 'Method',
  [7] = 'Property',
  [8] = 'Field',
  [9] = 'Constructor',
  [10] = 'Enum',
  [11] = 'Interface',
  [12] = 'Function',
  [13] = 'Variable',
  [14] = 'Constant',
  [15] = 'String',
  [16] = 'Number',
  [17] = 'Boolean',
  [18] = 'Array',
  [19] = 'Object',
  [20] = 'Key',
  [21] = 'Null',
  [22] = 'EnumMember',
  [23] = 'Struct',
  [24] = 'Event',
  [25] = 'Operator',
  [26] = 'TypeParameter',
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
  return { '@' }
end

source.complete = function(self, _, callback)
  local client = self:_get_client()
  client.request('textDocument/documentSymbol', { textDocument = vim.lsp.util.make_text_document_params() }, function(err, res)
    if err then
      return callback()
    end

    local items = {}
    local traverse
    traverse = function(nodes, level)
      level = level or 0
      for _, node in ipairs(nodes) do
        local kind_name = SymbolKind[node.kind]
        if vim.tbl_contains({ 'Module', 'Namespace', 'Object', 'Class', 'Interface', 'Method', 'Function' }, kind_name) then
          local line = vim.api.nvim_buf_get_lines(0, node.range.start.line, node.range.start.line + 1, false)[1] or ''
          table.insert(items, {
            label = ('%s%s'):format(string.rep(' ', level), string.gsub(line, '^%s*', '')),
            insertText = ('\\%%%sl'):format(node.range.start.line + 1),
            filterText = '@' .. node.name,
            sortText = '' .. node.range.start.line,
            kind = node.kind,
            data = node,
          })
          traverse(node.children or {}, level + 1)
        end
      end
    end
    traverse(res or {})
    callback(items)
  end)
end

source._get_client = function(self)
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if self:_get(client.server_capabilities, { 'documentSymbolProvider' }) then
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
