"""
bitarray.pony

Bitarray is an abstraction over Array[U8] that mimic an Array[Bool] where each
Bool value is a bit. It's three time slower at insertion (200M op/s vs
600M op/s for Array[Bool]), but it's seven times smaller (33M vs 240M for a
100M elements array)

Time vs space as usual.

The other use case is to easily pusha random number of bits into a buffer. Many
compression algoriths need this at some point.
"""

use "collections"
use dbg = "debug"

class BitarrayValues is Iterator[Bool]
  var _idx: USize = 0
  let _array: Bitarray box

  new create(ba: Bitarray box) =>
    _array = ba

  fun has_next(): Bool =>
    _array.size() > _idx

  fun ref next(): Bool ? =>
    _array(_idx = _idx + 1)?

class  Bitarray is Seq[Bool]
  let _array: Array[U8]
  var _size: USize = 0
  new create(len: USize val = 0) =>
    (var octet_idx, let bit_idx) = len.divrem_unsafe(8)
    if bit_idx != 0 then
      octet_idx = octet_idx + 1
    end

    _array = Array[U8](octet_idx)

  new init(from: Bool, len: USize) =>
    let from' = if from then U8(255) else U8(0) end

    (var octet_idx, let bit_idx) = len.divrem_unsafe(8)
    if bit_idx != 0 then
      octet_idx = octet_idx + 1
    end

    _array = Array[U8].init(from', octet_idx)
    _size = len


  fun apply(index: USize): Bool ? =>
    """
    Fetch the element a position index.
    """
    if (index + 1) > _size then error end
    (let octet_idx, let bit_idx) = index.divrem_unsafe(8)
    let octet = _array(octet_idx)?
    let mask = 1 << bit_idx.u8()
    (octet and mask) != 0

  fun ref push(value: Bool) =>
    """
    Adds an element to the end of the array.
    """
    (let octet_idx, let bit_idx) = _size.divrem_unsafe(8)
    if bit_idx == 0 then
      _array.push(0)
    end
    _size = _size + 1
    try update(_size - 1, value)? end

  fun values(): BitarrayValues^ =>
    """
    Returns an iterator over the elements.
    """
    BitarrayValues(this)

  fun ref update(i: USize val, value: Bool): Bool ? =>
    """
    Update the element at i and return the old value
    """
    if (i + 1)> _size then error end
    (let octet_idx, let bit_idx) = i.divrem_unsafe(8)
    let octet = _array(octet_idx)?
    var mask = U8(1) << bit_idx.u8()
    let new_byte = if value then (octet or mask) else (octet and (U8(255) xor mask)) end
    let result = (octet and mask) != 0
    if result != value then
      _array.update(octet_idx, new_byte)?
    end
    result

  fun size():USize =>
    """
    Returns the number of elements in the Bitarray.
    """
    _size

  fun bytes_size():USize =>
    """
    Returns the number of bytes to represent the Bitarray
    """
    _array.size()

  fun bytes(): ArrayValues[U8 val, this->Array[U8 val] ref] ref^ =>
    _array.values()

  fun debug(): String =>
    """
    Nice string representation. Although grouped by octets, It's NOT a
    representation of the underlying bytes, as it reads left to right.
    """
    let result = recover trn String() end
    result.push('[')
    var done: USize = 0
    for octet in _array.values() do
      for bit in Range(0, 8) do
        if done >= _size then break end
        if (bit == 0) and (done != 0) then
          result.push(' ')
        end
        done = done + 1
        result.push(
          if ( octet and (1 << bit.u8()) ) != 0 then
            '1'
          else
            '0'
          end
        )
      end
    end
    result.push(']')
    consume val result

  fun ref reserve(len: USize) =>
    """
    Reserve space for len elements.
    """
    (var octet_idx, let bit_idx) = len.divrem_unsafe(8)
    if bit_idx != 0 then
      octet_idx = octet_idx + 1
    end
    _array.reserve(octet_idx)

  fun ref clear() =>
    """
    Removes all elements from the sequence.
    """
    _array.clear()
    _size = 0

  fun ref pop(): Bool^ ? =>
    """
    Removes an element from the end of the sequence.
    """
    if _size == 0 then error end
    let result = apply(_size - 1)?
    _size = _size - 1
    let bit_idx = _size.rem(8)
    if bit_idx == 0 then
      _array.pop()?
    end
    result

  fun ref unshift(value: Bool) =>
    """
    Adds an element to the beginning of the array.
    """
    let new_byte = if value then U8(1) else U8(0) end
    _array.unshift(new_byte)
    _size = _size + 8
    for b in Range(8, _size) do
      try update(b-7, apply(b)?)? end
    end
    _size = _size - 7

  fun ref shift(): Bool^ ? =>
    """
    Removes an element from the beginning of the sequence.
    """
    if _size == 0 then error end
    var result: U8 = 0

    var remain = U8(0)
    for i in Range(0, _array.size()) do
      let octet = _array(i)?
      remain = if (U8(1) and octet) == 1 then 128 else 0 end
      if i > 0 then
        _array.update(i - 1, _array(i - 1)? or remain)?
      else
        result = U8(1) and octet
      end
      _array.update(i, octet >> 1)?
    end

    _size = _size - 1

    if _size.rem(8) == 0 then
      _array.pop()?
    end

    result == 1

  fun ref append(seq: (ReadSeq[Bool] & ReadElement[Bool^]), offset: USize = 0,
    len: USize = -1) =>
    """
    Add len elements to the end of the array, starting from the given
    offset.
    """
    if offset >= seq.size() then
      return
    end

    let copy_len = len.min(seq.size() - offset)

    var n = USize(0)

    try
      while n < copy_len do
        push(seq(offset + n)?)
        n = n + 1
      end
    end

  fun ref concat(iter: Iterator[Bool^], offset: USize = 0, len: USize = -1) =>
    """
    Add len iterated elements to the end of the list, starting from the given
    offset.
    """
    var done: USize = 0

    for v in iter do
      if offset <= (done = done + 1) then
        done = 0
        if len > (done = done + 1) then
          push(v)
        end
        break
      end
    end

    for v in iter do
      if len > (done = done + 1) then
        push(v)
      else
        break
      end
    end

  fun ref truncate(len: USize) =>
    """
    Truncate the sequence to the given length, discarding excess elements.
    If the sequence is already smaller than len, do nothing.
    """
    if len < _size then
      (var octet_idx, let bit_idx) = len.divrem_unsafe(8)
      if bit_idx != 7 then
        octet_idx = octet_idx + 1
      end
      _array.truncate(octet_idx)
      _size = len
    end
