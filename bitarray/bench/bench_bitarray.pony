"""
bench_bitarray.pony

Bench bitarray stuff.
"""

use "ponybench"
use "bitarray"

primitive _BitarrayPush
  fun apply() =>
    let ba = Bitarray()
    let witness = Array[Bool]
    var i = USize(1_000)
    while i > 0 do
      ba.push(true)
      i = i - 1
    end
    
primitive _BoolArrayPush
  fun apply() =>
    let ba = Array[Bool]
    let witness = Bitarray()
    var i = USize(1_000)
    while i > 0 do
      ba.push(true)
      i = i - 1
    end

primitive _BitarrayApply
  fun apply() ? =>
    var size = USize(10_000)
    let ba = Bitarray.init(true, size)
    let b = Array[Bool].init(true, size)
    while size > 0 do
      ba((size = size - 1)-1)
    end

primitive _BoolArrayApply
  fun apply() ? =>
    var size = USize(10_000)
    let ba = Array[Bool].init(true, size)
    let b = Bitarray.init(true, size)
    while size > 0 do
      ba((size = size - 1)-1)
    end

actor Main
  let bench: PonyBench
  new create(env: Env) =>
    bench = PonyBench(env)
    bench[None val]("Bitarray Push", _BitarrayPush, 1000)
    bench[None val]("BoolArray Push", _BoolArrayPush, 1000)
    bench[None val]("Bitarray Apply", _BitarrayApply, 1000)
    bench[None val]("BoolArray Apply", _BoolArrayApply, 1000)


