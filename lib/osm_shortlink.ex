defmodule OsmShortlink do
  use Bitwise
  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_~"
  @bits_32 1 <<< 32
  @doc """
  Function calculates the openstreetmap short link 
  see http://wiki.openstreetmap.org/wiki/Shortlink

  Its a port to elixir of the erlang code made by Krzysztof Marciniak - Public Domain

  other implementations are:

  https://github.com/openstreetmap/openstreetmap-website/blob/master/lib/short_link.rb

  https://github.com/openstreetmap/openstreetmap-website/blob/master/app/assets/javascripts/application.js

  based on https://gist.github.com/mdornseif/5652824 by Maximillian Dornseif

      iex> OsmShortlink.generate_link(51.5110,0.0550, 16)
      "http://osm.org/go/0EEQjEEb"
      iex> OsmShortlink.generate_link(51.5110,0.0550, 9)
      "http://osm.org/go/0EEQjE--"
      iex> OsmShortlink.generate_link(51.5110,0.0550, 9, true)
      "http://osm.org/go/0EEQjE--?m"
  """
  def generate_link(lat, lng, zoom, marker \\ false)

  @spec generate_link(number(), number(), pos_integer(), boolean()) :: binary()
  def generate_link(lat, lng, zoom, marker) when zoom >= 0 do
    x = trunc((lng + 180) * @bits_32 / 360)
    y = trunc((lat + 90) * @bits_32 / 180)

    <<code::64>> = interleave_bits(<<x::32>>, <<y::32>>)

    zoom_var = ceil((zoom + 8) / 3.0) - 1

    link_code = generate_link_code(code, zoom_var, [])
    zoom_remainder = zoom_remainder(zoom)

    generate_string(link_code, zoom_remainder, marker)
  end

  @spec interleave_bits(binary(), binary()) :: binary()

  defp interleave_bits(
         <<a1::1, a2::1, a3::1, a4::1, a5::1, a6::1, a7::1, a8::1, a9::1, a10::1, a11::1, a12::1,
           a13::1, a14::1, a15::1, a16::1, a17::1, a18::1, a19::1, a20::1, a21::1, a22::1, a23::1,
           a24::1, a25::1, a26::1, a27::1, a28::1, a29::1, a30::1, a31::1, a32::1>>,
         <<b1::1, b2::1, b3::1, b4::1, b5::1, b6::1, b7::1, b8::1, b9::1, b10::1, b11::1, b12::1,
           b13::1, b14::1, b15::1, b16::1, b17::1, b18::1, b19::1, b20::1, b21::1, b22::1, b23::1,
           b24::1, b25::1, b26::1, b27::1, b28::1, b29::1, b30::1, b31::1, b32::1>>
       ) do
    <<a1::1, b1::1, a2::1, b2::1, a3::1, b3::1, a4::1, b4::1, a5::1, b5::1, a6::1, b6::1, a7::1,
      b7::1, a8::1, b8::1, a9::1, b9::1, a10::1, b10::1, a11::1, b11::1, a12::1, b12::1, a13::1,
      b13::1, a14::1, b14::1, a15::1, b15::1, a16::1, b16::1, a17::1, b17::1, a18::1, b18::1,
      a19::1, b19::1, a20::1, b20::1, a21::1, b21::1, a22::1, b22::1, a23::1, b23::1, a24::1,
      b24::1, a25::1, b25::1, a26::1, b26::1, a27::1, b27::1, a28::1, b28::1, a29::1, b29::1,
      a30::1, b30::1, a31::1, b31::1, a32::1, b32::1>>
  end

  @spec generate_link_code(pos_integer(), integer(), list()) :: String.t()
  defp generate_link_code(_, -1, ret), do: :erlang.list_to_binary(ret)

  defp generate_link_code(code, z, ret) do
    digit = code >>> (58 - 6 * z) &&& 63
    generate_link_code(code, z - 1, [String.at(@chars, digit) | ret])
  end

  @spec zoom_remainder(integer()) :: String.t()
  defp zoom_remainder(zoom) do
    :binary.part("--", 0, rem(zoom + 8, 3))
  end

  @spec generate_string(String.t(), String.t(), boolean()) :: String.t()
  defp generate_string(code, zoom, marker) do
    IO.chardata_to_string(["http://osm.org/go/", code, zoom, if(marker, do: "?m", else: "")])
  end

  @doc """
  Restores the coordinates from link

      iex> OsmShortlink.link_to_coordinates("http://osm.org/go/0EEQjE--")
      {51.510772705078125, 0.054931640625}
      iex> OsmShortlink.link_to_coordinates("http://osm.org/go/0EEQjE?M")
      {51.510772705078125, 0.054931640625}
  """
  @spec link_to_coordinates(String.t()) :: {float(), float()}
  def link_to_coordinates("https://osm.org/go/" <> link) do
    link_to_coordinates(link)
  end

  def link_to_coordinates("http://osm.org/go/" <> link) do
    link_to_coordinates(link)
  end

  def link_to_coordinates(link) do
    link
    |> String.split(["-", "?"])
    |> hd()
    |> String.graphemes()
    |> Enum.map(fn char -> :binary.match(@chars, char) |> elem(0) end)
    |> Enum.reverse()
    |> Enum.reduce(<<>>, fn six_bit_val, acc -> <<six_bit_val::6, acc::bits>> end)
    |> restore_coords("", "")
  end

  @spec restore_coords(binary(), binary(), binary()) :: {float(), float()}
  defp restore_coords(<<a1::1, b1::1, rest::bits>> = _interleaved_bits, a, b) do
    restore_coords(rest, <<a::bits, a1::1>>, <<b::bits, b1::1>>)
  end

  defp restore_coords("", a, b) do
    if bit_size(a) < 32 do
      restore_coords("", <<a::bits, 0::1>>, <<b::bits, 0::1>>)
    else
      {restore_coord(b, 1), restore_coord(a, 2)}
    end
  end

  @spec restore_coord(binary(), 1 | 2) :: float()
  defp restore_coord(coord, multiplier) do
    :binary.decode_unsigned(coord) * (180 * multiplier) / @bits_32 - multiplier * 90
  end
end
