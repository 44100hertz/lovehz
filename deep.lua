local deep = {}

function deep.copy ()
   local dup = {}
   for k,_ in pairs(t) do
      local v = rawget(t, k)
      if type(v) == 'table' then v = deep.copy(v) end
      dup[k] = v
   end
   setmetatable(dup, getmetatable(t))
   return dup
end

function deep.print (t)
  print(deep.tostring(t))
end

function deep.tostring (value, indent_level, seen)
   seen = seen or {}
   indent_level = indent_level or 1
   local indent_size = 3
   if type(value) == 'table' then
      if seen[value] then
         return '<<Self-referential value>>'
      end
      seen[value] = true
      local indent_string = string.rep(' ', indent_level * indent_size)
      local lines = {}
      lines[#lines+1] = '{'
      for k,v in pairs(value) do
         lines[#lines+1] = string.format('%s[%s] = %s,',
                                         indent_string,
                                         deep.tostring(k, indent_level+1, seen),
                                         deep.tostring(v, indent_level+1, seen))
      end
      lines[#lines+1] = (' '):rep((indent_level-1) * indent_size) .. '}'
      return table.concat(lines, '\n')
   elseif type(value) == 'string' then
      return string.format("%q", value):gsub('\\\n', '\\n')
   elseif type(value) == 'number' then
      return tostring(value)
   elseif type(value) == 'nil' then
      return 'nil'
   elseif type(value) == 'boolean' then
      return value and 'true' or 'false'
   else
      return string.format('<<Value of type %s>>', type(value))
   end
end

return deep
