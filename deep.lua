local deep = {}

function deep.copy (t)
   return deep._copy(t, {})
end

function deep._copy (t, seen)
   if type(t) == 'table' then
      if seen[t] then
         error('recursive table')
      end
      seen[t] = true
      local dup = {}
      for k,_ in pairs(t) do
         local v = rawget(t, k)
         dup[k] = deep._copy(v, seen)
      end
      setmetatable(dup, getmetatable(t))
      return dup
   else
      return t
   end
end

function deep.print (t)
  print(deep.tostring(t))
end

function deep.equals (t1, t2)
   if type(t1) ~= type(t2) then
      return false
   elseif type(t1) == 'table' then
      if getmetatable(t1) ~= getmetatable(t2) then
         return false
      end
      -- First, make sure all of t1 is equal to t2
      for k1,v1 in pairs(t1) do
         if not deep.equals(v1, t2[k1]) then
            return false
         end
      end
      -- Second, make sure that t2 doesn't contain anything outside of t1
      for k2,v2 in pairs(t2) do
         if t1[k2] == nil then
            return false
         end
      end
      return true
   else
      return t1 == t2
   end
end

function deep.serialize (value)
   return deep._tostring(value, 1, {}, true)
end

function deep.tostring (value)
   return deep._tostring(value, 1, {}, false)
end

function deep._tostring (value, indent_level, seen, serialize)
   local indent_size = 3
   if type(value) == 'table' then
      if seen[value] then
         if serialize then
            error('Self-referential value')
         else
            return '<<Self-referential value>>'
         end
      end
      seen[value] = true
      local indent_string = string.rep(' ', indent_level * indent_size)
      local lines = {}
      lines[#lines+1] = '{'
      for k,v in pairs(value) do
         lines[#lines+1] = string.format('%s[%s] = %s,',
                                         indent_string,
                                         deep._tostring(k, indent_level+1, seen, serialize),
                                         deep._tostring(v, indent_level+1, seen, serialize))
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
      if serialize then
         error(string.format('Cannot serialize value %s', value))
      else
         return string.format('%s', value)
      end
   end
end

function deep.flatten (t)
   return deep._flatten(t, {})
end

function deep._flatten (t, out)
   if type(t) == 'table' then
      for k,v in pairs(t) do
         if type(v) == 'table' then
            deep._flatten(v, out)
         else
            if out[k] and out[k] ~= t[k] then
               error(string.format('cannot flatten conflict keyvalues:\n %s = %s and %s = %s', k, out[k], k, t[k]))
            else
               out[k] = v
            end
         end
      end
      return out
   else
      return t
   end
end

return deep
