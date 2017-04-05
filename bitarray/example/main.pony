"""
bitarray.pony

Bitarray usage example
"""
use "bitarray"


actor Main
  new create(env: Env) =>
    let ba = Bitarray()
    env.out.print("Hello")
    ba.push(true)
    env.out.print(ba.debug())
    ba.push(false)
    env.out.print(ba.debug())
    ba.push(true)
    env.out.print(ba.debug())
    ba.push(false)
    env.out.print(ba.debug())
    ba.push(false)
    env.out.print(ba.debug())
    ba.push(true)
    env.out.print(ba.debug())
    ba.push(true)
    env.out.print(ba.debug())
    ba.push(false)
    env.out.print(ba.debug())

    ba.push(true)
    env.out.print(ba.debug())
    ba.push(false)
    env.out.print(ba.debug())
    ba.push(false)
    env.out.print(ba.debug())
    ba.push(true)
    env.out.print(ba.debug())

    try
      env.out.print(ba(0).string())
      env.out.print(ba(1).string())
      env.out.print(ba(2).string())
    end

    try ba.update(1, true) end
    env.out.print(ba.debug())
    try ba.update(1, false) end
    env.out.print(ba.debug())

    ba.unshift(false)
    env.out.print(ba.debug())

    for b in ba.values() do
      env.out.print(b.string())
    end
