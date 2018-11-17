"""
bench_bitarray.pony

Bench bitarray stuff.
"""

use "ponybench"
use "../../bitarray"

class iso _BitarrayPush is MicroBenchmark
  fun name(): String => "Bitarray Push"

  fun ref apply() =>
    let ba = Bitarray()
    let witness = Array[Bool]
    var i = USize(1_000)
    while i > 0 do
      ba.push(true)
      i = i - 1
    end
    
class iso _BoolArrayPush is MicroBenchmark
  fun name(): String => "BoolArray Push"

  fun ref apply() =>
    let ba = Array[Bool]
    let witness = Bitarray()
    var i = USize(1_000)
    while i > 0 do
      ba.push(true)
      i = i - 1
    end

class iso _BitarrayApply is MicroBenchmark
  fun name(): String => "Bitarray Apply"

  fun ref apply() ? =>
    var size = USize(10_000)
    let ba = Bitarray.init(true, size)
    let b = Array[Bool].init(true, size)
    while size > 0 do
      ba((size = size - 1)-1)?
    end

class iso _BoolArrayApply is MicroBenchmark
  fun name(): String => "BoolArray Apply"

  fun ref apply() ? =>
    var size = USize(10_000)
    let ba = Array[Bool].init(true, size)
    let b = Bitarray.init(true, size)
    while size > 0 do
      ba((size = size - 1)-1)?
    end

actor Main is BenchmarkList
  new create(env: Env) =>
    PonyBench(env, this)

  fun tag benchmarks(bench: PonyBench) =>
    bench(_BitarrayPush)
    bench(_BoolArrayPush)
    bench(_BitarrayApply)
    bench(_BoolArrayApply)


