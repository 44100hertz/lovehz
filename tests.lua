local test = require 'tests/u-test/u-test'
local Point2 = require 'Point2'
local deep = require 'deep'

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
   test.is_true(deep.equals(true, true))
   test.is_true(deep.equals({}, {}))
   test.is_false(deep.equals({}, true))
   test.is_false(deep.equals({}, {true}))
   test.is_true(deep.equals({{}}, {{}}))
   test.is_true(deep.equals({{1}, 1}, {{1}, 1}))
   test.is_true(deep.equals({false}, {false}))
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
   test.is_true(deep.equals(loadstring('return ' .. deep.tostring(tt))(), tt))

   local ttt = {{1},2,{3,{4,5},6},7}
   test.is_true(deep.equals(loadstring('return ' .. deep.tostring(ttt))(), ttt))
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
   test.is_true(deep.equals(loadstring('return ' .. deep.serialize(tt))(), tt))

   local ttt = {{1},2,{3,{4,5},6},7}
   test.is_true(deep.equals(loadstring('return ' .. deep.serialize(ttt))(), ttt))
end
