# pony-bitarray

[![Build Status](https://travis-ci.org/d-led/pony-bitarray.svg?branch=master)](https://travis-ci.org/d-led/pony-bitarray)

Bitarray is an abstraction over Array[U8] that mimic an Array[Bool] where each
Bool value is a bit. It's three time slower at insertion (200M op/s vs
600M op/s for Array[Bool]), but it's seven times smaller (33M vs 240M for a
100M elements array)

Time vs space as usual.

The other use case is to easily push a random number of bits into a buffer. Many
compression algoriths need this at some point.
