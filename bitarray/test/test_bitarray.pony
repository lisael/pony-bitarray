"""
test_bitarray.pony

Test bitarray stuff.
"""

use "ponytest"
use "bitarray"

primitive _GetTestArray
  fun apply(): Bitarray ref^ =>
    let a = Bitarray()
    a.push(true)
    a.push(false)
    a.push(true)
    a.push(true)
    a.push(false)
    a.push(false)
    a.push(true)
    a.push(true)
    a.push(true)
    a.push(false)
    a.push(false)
    a.push(false)
    a


actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() =>
    None

  fun tag tests(test: PonyTest) =>
    test(_TestPush)
    test(_TestApply)
    test(_TestUpdate)
    test(_TestClear)
    test(_TestPop)
    test(_TestUnshift)
    test(_TestConcat)

class iso _TestConcat is UnitTest
  fun name():String => "Concat"
  fun apply(h: TestHelper) =>
    let a = Bitarray()
    h.assert_eq[String](a.debug(), "[]")
    var ba : Array[Bool] = [true; false; false; true]
    a.concat(ba.values())
    h.assert_eq[String](a.debug(), "[1001]")
    a.clear()
    a.concat(ba.values(), 1, 2)
    h.assert_eq[String](a.debug(), "[00]")

class iso _TestUnshift is UnitTest
  fun name():String => "Unshift"
  fun apply(h: TestHelper) =>
    let a = Bitarray()
    h.assert_eq[String](a.debug(), "[]")
    a.unshift(false)
    h.assert_eq[String](a.debug(), "[0]")
    a.unshift(true)
    h.assert_eq[String](a.debug(), "[10]")
    a.unshift(false)
    h.assert_eq[String](a.debug(), "[010]")

class iso _TestPush is UnitTest
  fun name():String => "Push"
  fun apply(h: TestHelper) =>
    let a = Bitarray()
    h.assert_eq[USize](a.size(), 0)
    h.assert_eq[USize](a.bytes_size(), 0)
    a.push(true)
    h.assert_eq[USize](a.size(), 1)
    h.assert_eq[USize](a.bytes_size(), 1)
    a.push(false)
    h.assert_eq[USize](a.size(), 2)
    h.assert_eq[USize](a.bytes_size(), 1)
    a.push(true)
    a.push(false)
    a.push(true)
    a.push(false)
    a.push(true)
    a.push(false)
    h.assert_eq[USize](a.bytes_size(), 1)
    a.push(true)
    h.assert_eq[USize](a.bytes_size(), 2)
    a.push(false)
    h.assert_eq[String](a.debug(), "[10101010 10]")

class iso _TestPop is UnitTest
  fun name(): String => "Pop"
  fun apply(h: TestHelper) ? =>
    var a = _GetTestArray()
    h.assert_eq[Bool](a.pop(), false)
    h.assert_eq[String](a.debug(), "[10110011 100]")
    h.assert_eq[USize](a.size(), 11)
    h.assert_eq[USize](a.bytes_size(), 2)
    a.pop()
    a.pop()
    a.pop()
    h.assert_eq[USize](a.size(), 8)
    h.assert_eq[USize](a.bytes_size(), 1)
    h.assert_eq[String](a.debug(), "[10110011]")
    a = Bitarray()
    try a.pop(); h.fail("Should raise an error") end


class iso _TestClear is UnitTest
  fun name(): String => "Clear"
  fun apply(h: TestHelper) =>
    let a = _GetTestArray()
    a.clear()
    h.assert_eq[String](a.debug(), "[]")
    h.assert_eq[USize](a.size(), 0)


class iso _TestUpdate is UnitTest
  fun name(): String => "Update"
  fun apply(h: TestHelper) ? =>
    let a = _GetTestArray()
    h.assert_eq[Bool](a.update(0, false), true)
    h.assert_eq[Bool](a.update(1, false), false)
    h.assert_eq[Bool](a.update(2, true), true)
    h.assert_eq[Bool](a(3), true)
    h.assert_eq[Bool](a.update(4, true), false)
    h.assert_eq[Bool](a(5), false)
    h.assert_eq[String](a.debug(), "[00111011 1000]")

class iso _TestApply is UnitTest
  fun name(): String => "Apply"
  fun apply(h: TestHelper) ? =>
    let a = _GetTestArray()
    h.assert_eq[USize](a.size(), 12)
    h.assert_eq[String](a.debug(), "[10110011 1000]")
    h.assert_eq[Bool](a(0), true)
    h.assert_eq[Bool](a(1), false)
    h.assert_eq[Bool](a(2), true)
    h.assert_eq[Bool](a(3), true)
    h.assert_eq[Bool](a(4), false)
    h.assert_eq[Bool](a(5), false)
    h.assert_eq[Bool](a(11), false)
    try a(12); h.fail("Should raise an error") end
