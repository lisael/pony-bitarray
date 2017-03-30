"""
test_bitarray.pony

Test bitarray stuff.
"""

use "ponytest"
use "bitarray"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() =>
    None

  fun tag tests(test: PonyTest) =>
    test(_TestAdd)

class iso _TestAdd is UnitTest

  fun name():String => "Contains"

  fun apply(h: TestHelper) =>
    h.assert_eq[I32](2+2, 4)

