# OsmShortlink

This library allowes to generate short links to any geo coordinates.
The longer the link the more precisce we can specify our desired position
[Description](https://wiki.openstreetmap.org/wiki/Shortlink)  I based it on the [erlang implementation](https://gist.github.com/yetihehe/5fe63901ca613822ac436dfcb45c4af0) and converted it to elixir, then refactored to be more readable and added a reverse function

## How it works:
[http://osm.org/go/0EEQjE12](http://osm.org/go/0EEQjE12--) is a valid url, so is [http://osm.org/go/0EE](http://osm.org/go/0EE) with removed 5 letteras, is still valid and pointing to the same area just less precise

	x = trunc((lng + 180) / 360  * (1 <<< 32)

this line makes the number positive in the range between 0..1
and then casts it to 32 bit integer (1 <<< 32 is just a fancy way of calculation 2^32)

having the coordinates as 32 bit indeger can be easily manipulated with binary functions and its fast
the most important stuff here is that the oldest bits are the more importnat ones - even if we remove half of the young ones we wont loose lots of accuracy
imagine we have a starting number of 5.4321 

	(5.4321 + 180) /360 * 2^32 =
	185.4321 / 360 * 2^32 =
	2212291125
	10000011_11011100_11100010_00110101
this now gets saved send somewhere and we are loosing second half of the information:

	10000011_11011100_00000000_00000000 converted to int
	2212233216
now lets reverse the calculation:

	2212233216 / 2 ^ 32
	0.51507568359 * 360 - 180
	5.427246094
we lost 50% of the information but are only

	0.00485390625 degree away - thats around 300-500m accuracy
when we loose 75% of the information

	2197815296 we are on 4.21875 so its still 1.21335 away
around 80-120km, we can still tell the country and region
every bit multiplies the accuracy by 2 so adding here 4 bits up to total of 12bits its (120km / 2^4) = around 10-16 km accuracy - you can tell the city

When we have the latitude and longitude in binary form we "zip" it
imagine we have for simplicity 6bit numbers instead of 32:

	111111
	000001
then our number that gets encoded is

	101010101011

it happens in the interleave_bits function by pattern matching on every bit:

	def interleave_bits(
		<<a1::1, a2::1, a3::1, a4::1, a5::1, a6::1>>,
		<<b1::1, b2::1, b3::1, b4::1, b5::1, b6::1>>
	), do: <<a1::1, b1::1, a2::1, b2::1, a3::1, b3::1, a4::1, b4::1, a5::1, b5::1, a6::1, b6::1>>
this is pretty straight forward we just take one bit from a then one from b then again one from a and so on

in 64 we can fit 6 bits so now we chunking our binary and encode it - it would look like 

	101010101010 >>> (58 - 6 * zoom_var) &&& 63

on every iteration of this function we take the 6 oldest bits and cast it to char
our magic number here is 63 which is 11111111bin
 &&& is binary AND: it just resets all the bits that are 0 to 0 and keeps the ones that are 1 on both

	101010101011 >>> (12 - 6 * 0) &&& 63
	101010101011 >>> 6 &&& 63
	101010101011 &&& 1111111 = 101011
on next iteration shift by 6 bits

	101010101011 >>> (12 - 6 * 1) &&& 63
	000000101010 &&& 1111111 = 101010

last thing we do here is a custom base64 encode function that does not use + and / these cant be used in urls

	@chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_~"

	101010bin is 42dec and its the letter q, 43 is r
	so our custom url is `/rq`

when reversing ist the same:

we search for our letters and get back rq which is 43 42 - 101010101011 binary

then we need to run a recursive function that takes the first 2 bits and add it to the end of 2 bitwords
then takes next to bits adding it again to the end of the word - shifting our bits to the front - this way the bist in front are the most omportant ones

	101010101011
	1010101011 1 0
	10101011   11 00
	101011     111 000
	1011       1111 0000
	11         11111 00000
	           111111 000001
we need a 32 bit words here to our function checks the lenght and if its not 32 bit then adds 0 to the end

	11111100000000000000000000000000 0000010000000000000000000000000
these now got converted to integers and then back to our coordinates

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `osm_shortlink` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:osm_shortlink, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/osm_shortlink](https://hexdocs.pm/osm_shortlink).

