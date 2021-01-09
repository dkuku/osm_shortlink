defmodule OsmShortlink do
  use Bitwise
  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_~"
  @doc """
  Function calculates the openstreetmap short link 
  see http://wiki.openstreetmap.org/wiki/Shortlink

  Its a port to elixir of the erlang code made by Krzysztof Marciniak - Public Domain

  other implementations are:

  https://github.com/openstreetmap/openstreetmap-website/blob/master/lib/short_link.rb

  https://github.com/openstreetmap/openstreetmap-website/blob/master/app/assets/javascripts/application.js

  based on https://gist.github.com/mdornseif/5652824 by Maximillian Dornseif


  iex(76)> OsmShortlink.osm_shortlink(51.5110,0.0550, 16)
  "http://osm.org/go/0EEQjEEb"
  iex(78)> OsmShortlink.osm_shortlink(51.5110,0.0550, 9)
  "http://osm.org/go/0EEQjE--"
  iex(79)> OsmShortlink.osm_shortlink(51.5110,0.0550, 9, true)
  "http://osm.org/go/0EEQjE--?m"
  """
  def osm_shortlink(lat, lng, zoom, marker \\ false)

  @spec osm_shortlink(number(), number(), pos_integer(), boolean()) :: binary()
  def osm_shortlink(lat, lng, zoom, marker) when zoom >= 0 do
    x = trunc((lng + 180) * (1 <<< 32) / 360)
    y = trunc((lat + 90) * (1 <<< 32) / 180)
    <<code::64>> = interleave_bits(<<x::32>>, <<y::32>>, "")

    zoom_var = ceil((zoom + 8) / 3.0) - 1
    link_code = osm_shortlink_code(code, zoom_var, [])
    zoom_remainder = zoom_remainder(zoom)

    generate_link(link_code, zoom_remainder, marker)
  end

  @spec interleave_bits(binary(), binary(), binary()) :: binary()
  defp interleave_bits("", "", ret), do: ret

  defp interleave_bits(<<a1::1, arest::bits>>, <<b1::1, brest::bits>>, ret) do
    interleave_bits(arest, brest, <<ret::bits, a1::1, b1::1>>)
  end

  @spec osm_shortlink_code(pos_integer(), integer(), list()) :: String.t()
  defp osm_shortlink_code(_, -1, ret), do: :erlang.list_to_binary(ret)

  defp osm_shortlink_code(code, z, ret) do
    digit = code >>> (58 - 6 * z) &&& 63
    osm_shortlink_code(code, z - 1, [String.at(@chars, digit) | ret])
  end

  @spec zoom_remainder(integer()) :: String.t()
  defp zoom_remainder(zoom) do
    :binary.part("--", 0, rem(zoom + 8, 3))
  end

  @spec generate_link(String.t(), String.t(), boolean()) :: String.t()
  defp generate_link(code, zoom, marker) do
    IO.chardata_to_string(["http://osm.org/go/", code, zoom, if(marker, do: "?m", else: "")])
  end
end
