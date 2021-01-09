defmodule OsmShortlinkTest do
  use ExUnit.Case
  doctest OsmShortlink

  test " adding marker true adds marker" do
    assert OsmShortlink.generate_link(51.5110, 0.0550, 9, true) == "http://osm.org/go/0EEQjE--?m"
  end

  test " adding marker false is not adding marker" do
    assert OsmShortlink.generate_link(51.5110, 0.0550, 9, false) == "http://osm.org/go/0EEQjE--"
  end

  test "lower zoom level removes zoom dashes" do
    assert OsmShortlink.generate_link(51.5110, 0.0550, 8, false) == "http://osm.org/go/0EEQjE-"
    assert OsmShortlink.generate_link(51.5110, 0.0550, 7, false) == "http://osm.org/go/0EEQj"
    assert OsmShortlink.generate_link(51.5110, 0.0550, 6, false) == "http://osm.org/go/0EEQj--"
    assert OsmShortlink.generate_link(51.5110, 0.0550, 5, false) == "http://osm.org/go/0EEQj-"
    assert OsmShortlink.generate_link(51.5110, 0.0550, 4, false) == "http://osm.org/go/0EEQ"
    assert OsmShortlink.generate_link(51.5110, 0.0550, 0, false) == "http://osm.org/go/0EE--"
  end

  test "higher zoom level makes the url longer" do
    assert OsmShortlink.generate_link(51.5110, 0.0550, 16, false) == "http://osm.org/go/0EEQjEEb"
  end

  test "bounds go round" do
    assert OsmShortlink.generate_link(-90, -180, 0, false) == "http://osm.org/go/AAA--"
    assert OsmShortlink.generate_link(90, -180, 0, false) == "http://osm.org/go/AAA--"
    assert OsmShortlink.generate_link(90, 180, 0, false) == "http://osm.org/go/AAA--"
    assert OsmShortlink.generate_link(-90, 180, 0, false) == "http://osm.org/go/AAA--"
    assert OsmShortlink.generate_link(-180, -90, 16, false) == "http://osm.org/go/YAAAAAAA"
    assert OsmShortlink.generate_link(-180, 90, 16, false) == "http://osm.org/go/4AAAAAAA"
    assert OsmShortlink.generate_link(180, 90, 16, false) == "http://osm.org/go/4AAAAAAA"
    assert OsmShortlink.generate_link(180, -90, 16, false) == "http://osm.org/go/YAAAAAAA"
    assert OsmShortlink.generate_link(-180, -90, 0, false) == "http://osm.org/go/YAA--"
    assert OsmShortlink.generate_link(-180, 90, 0, false) == "http://osm.org/go/4AA--"
    assert OsmShortlink.generate_link(180, 90, 0, false) == "http://osm.org/go/4AA--"
    assert OsmShortlink.generate_link(180, -90, 0, false) == "http://osm.org/go/YAA--"
  end

  test "bounds" do
    assert OsmShortlink.generate_link(0, 0, 0, false) == "http://osm.org/go/wAA--"
    assert OsmShortlink.generate_link(90, 0, 16, false) == "http://osm.org/go/gAAAAAAA"
    assert OsmShortlink.generate_link(-90, 0, 16, false) == "http://osm.org/go/gAAAAAAA"
    assert OsmShortlink.generate_link(0, 180, 16, false) == "http://osm.org/go/QAAAAAAA"
    assert OsmShortlink.generate_link(0, -180, 16, false) == "http://osm.org/go/QAAAAAAA"
    assert OsmShortlink.generate_link(0, 0, 16, false) == "http://osm.org/go/wAAAAAAA"
  end
end
