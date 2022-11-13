local test = require 'tests/u-test/u-test'
local Point2 = require 'Point2'
local deep = require 'deep'

local function deep_equal (a, b)
   if deep.equals(a, b) then
      return true
   else
      local err = string.format("Values not equal:\n%s\n%s", deep.tostring(a), deep.tostring(b))
      return false, err
   end
end
test.register_assert('deep_equal', deep_equal)

test.point = function ()
  local p = Point2(2, 4)
  test.equal(p.x, 2)
  test.equal(p.y, 4)

  local q = Point2(3, 5)
  local between = p:lerp(q, 0.5)

  test.equal(between.x, 2.5)
  test.equal(between.y, 4.5)

  test.not_equal(p, q)
  test.equal(Point2(2, 4), Point2(2, 4))

  test.is_true(Point2(1,1):within_rectangle(0,0,2,2))
  test.is_false(Point2(1,3):within_rectangle(0,0,2,2))
  test.is_false(Point2(3,1):within_rectangle(0,0,2,2))
  test.is_false(Point2(3,3):within_rectangle(0,0,2,2))
  test.is_true(Point2(-1,-1):within_rectangle(-2,-2,2,2))
  test.is_false(Point2(-2,-1):within_rectangle(-1,-1,2,2))

  test.equal(Point2(0,0):length(), 0)
  test.equal(Point2(0,1):length(), 1)
  test.equal(Point2(1,1):length(), math.sqrt(2))

  test.equal(Point2(1,1):distance_to(Point2(-1,-1)), math.sqrt(8))
  test.equal(Point2(-1,-1):distance_to(Point2(1,1)), math.sqrt(8))

  test.equal(Point2(1,1):normalize(), Point2(1/math.sqrt(2), 1/math.sqrt(2)))
end

test.deepEquals = function ()
   test.deep_equal(true, true)
   test.deep_equal({}, {})
   test.is_false(deep.equals({}, true))
   test.is_false(deep.equals({}, {true}))
   test.deep_equal({{}}, {{}})
   test.deep_equal({{1}, 1}, {{1}, 1})
   test.deep_equal({false}, {false})
   test.is_false(deep.equals({false}, {}))
   local t1 = {}
   local t2 = setmetatable({}, {})
   test.is_false(deep.equals(t1, t2))
end

test.deepToString = function ()
   test.equal(deep.tostring(1), '1')
   test.equal(deep.tostring('hello'), '"hello"')
   test.equal(deep.tostring('\9hello\n'), '"\\9hello\\n"')
   test.equal(deep.tostring('"hello"'), '"\\"hello\\""')
   test.equal(deep.tostring(true), 'true')
   test.equal(deep.tostring({}), [[
{
}]])
   test.is_not_nil(string.find(deep.tostring(function () end), 'function'))

   local t = {}
   t.t = t
   test.equal(deep.tostring(t), [[
{
   ["t"] = <<Self-referential value>>,
}]])

   local tt = {1,
               'hello',
               ['1'] = '1',
               hello = 'hello',
               [true] = false
   }
   test.deep_equal(loadstring('return ' .. deep.tostring(tt))(), tt)

   local ttt = {{1},2,{3,{4,5},6},7}
   test.deep_equal(loadstring('return ' .. deep.tostring(ttt))(), ttt)
end

test.deepSerialize = function ()
   test.equal(deep.serialize(1), '1')
   test.equal(deep.serialize('hello'), '"hello"')
   test.equal(deep.serialize('\9hello\n'), '"\\9hello\\n"')
   test.equal(deep.serialize('"hello"'), '"\\"hello\\""')
   test.equal(deep.serialize(true), 'true')
   test.equal(deep.serialize({}), [[
{
}]])
   test.error_raised(function () deep.serialize(function () end) end, 'Cannot serialize value')
   local t = {}
   t.t = t
   test.error_raised(function () deep.serialize(t) end, 'Self-referential value')

   local tt = {1,
               'hello',
               ['1'] = '1',
               hello = 'hello',
               [true] = false
   }
   test.deep_equal(loadstring('return ' .. deep.serialize(tt))(), tt)

   local ttt = {{1},2,{3,{4,5},6},7}
   test.deep_equal(loadstring('return ' .. deep.serialize(ttt))(), ttt)
end

test.deepCopy = function ()
   test.deep_equal(deep.copy(true), true)
   test.deep_equal(deep.copy({}), {})
   local tt = {1,
               'hello',
               ['1'] = '1',
               hello = 'hello',
               [true] = false
   }
   test.deep_equal(deep.copy(tt), tt)
   local ttt = {{1},2,{3,{4,5},6},7}
   test.deep_equal(deep.copy(ttt), ttt)

   local class = {
      inc = function (self) self.count = self.count + 1 end
   }
   local object = setmetatable({count=10}, {__index = class})
   test.deep_equal(deep.copy(object), object)

   local t = {}
   t.t = t
   test.error_raised(function () deep.copy(t) end, 'recursive')

   local t1 = {}
   t1.a = function () return 1 end
   local t2 = deep.copy(t1)
   test.equal(t2.a(), 1)
   t2.a = function () return 2 end
   test.equal(t1.a(), 1)
   test.equal(t2.a(), 2)
end

test.deepFlatten = function ()
   test.deep_equal(deep.flatten(true), true)
   test.deep_equal(deep.flatten({}), {})
   test.deep_equal(deep.flatten({1}), {1})
   test.deep_equal(deep.flatten({{1}}), {1})
   test.deep_equal(deep.flatten({h = 1, {i = 2}}), {h = 1, i = 2})
   test.deep_equal(deep.flatten({h = 1, {i = 2}, {j = 3, {k = 4}}}), {h = 1, i = 2, j = 3, k = 4})
   test.deep_equal(deep.flatten({h = 1, {h = 1}}), {h = 1})
   test.error_raised(function () deep.flatten({h = 1, {h = 2}}) end, 'conflict')
end
