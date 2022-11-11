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

test.deepToString = function ()
   test.equal(deep.tostring(1), '1')
   test.equal(deep.tostring('hello'), '"hello"')
   test.equal(deep.tostring('\9hello\n'), '"\\9hello\\n"')
   test.equal(deep.tostring('"hello"'), '"\\"hello\\""')
   test.equal(deep.tostring(true), 'true')
   test.equal(deep.tostring({}), [[
{
}]])
   test.equal(deep.tostring(function () end), '<<Value of type function>>')

   local t = {}
   t.t = t
   test.equal(deep.tostring(t), [[
{
   ["t"] = <<Self-referential value>>,
}]])

   test.equal(deep.tostring({1,
                             'hello',
                             ['1'] = '1',
                             hello = 'hello',
                             [true] = false,}), [[
{
   [1] = 1,
   [2] = "hello",
   ["1"] = "1",
   [true] = false,
   ["hello"] = "hello",
}]])

   test.equal(deep.tostring({{},{{}}}), [[
{
   [1] = {
   },
   [2] = {
      [1] = {
      },
   },
}]])
end
