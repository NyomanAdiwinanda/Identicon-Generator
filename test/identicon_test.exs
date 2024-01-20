defmodule IdenticonTest do
  use ExUnit.Case
  doctest Identicon

  test "hash_input" do
    assert Identicon.hash_input("adi") ==
      %Identicon.Image{
        hex: [196, 99, 53, 235, 38, 126, 46, 28, 222, 91, 1, 122, 203, 76, 215, 153],
        color: nil,
        grid: nil,
        pixel_map: nil
      }
  end

  test "pick_color" do
    result = Identicon.hash_input("adi")
    assert Identicon.pick_color(result) ==
      %Identicon.Image{
        hex: [196, 99, 53, 235, 38, 126, 46, 28, 222, 91, 1, 122, 203, 76, 215, 153],
        color: {196, 99, 53},
        grid: nil,
        pixel_map: nil
      }
  end

  test "build_grid" do
    result = Identicon.hash_input("adi")
    Identicon.pick_color(result)
    assert Identicon.build_grid(result) ==
      %Identicon.Image{
        hex: [196, 99, 53, 235, 38, 126, 46, 28, 222, 91, 1, 122, 203, 76, 215, 153],
        color: nil,
        grid: [
          {196, 0},
          {99, 1},
          {53, 2},
          {99, 3},
          {196, 4},
          {235, 5},
          {38, 6},
          {126, 7},
          {38, 8},
          {235, 9},
          {46, 10},
          {28, 11},
          {222, 12},
          {28, 13},
          {46, 14},
          {91, 15},
          {1, 16},
          {122, 17},
          {1, 18},
          {91, 19},
          {203, 20},
          {76, 21},
          {215, 22},
          {76, 23},
          {203, 24}
        ],
        pixel_map: nil
      }
  end

  test "filter_odd_squares" do
    result = Identicon.hash_input("adi")
    Identicon.pick_color(result)
    result = Identicon.build_grid(result)
    assert Identicon.filter_odd_squares(result) ==
      %Identicon.Image{
        hex: [196, 99, 53, 235, 38, 126, 46, 28, 222, 91, 1, 122, 203, 76, 215, 153],
        color: nil,
        grid: [
          {196, 0},
          {196, 4},
          {38, 6},
          {126, 7},
          {38, 8},
          {46, 10},
          {28, 11},
          {222, 12},
          {28, 13},
          {46, 14},
          {122, 17},
          {76, 21},
          {76, 23}
        ],
        pixel_map: nil
      }
  end

  test "build_pixel_map" do
    result = Identicon.hash_input("adi")
    Identicon.pick_color(result)
    result = Identicon.build_grid(result)
    result = Identicon.filter_odd_squares(result)
    assert Identicon.build_pixel_map(result) ==
      %Identicon.Image{
        hex: [196, 99, 53, 235, 38, 126, 46, 28, 222, 91, 1, 122, 203, 76, 215, 153],
        color: nil,
        grid: [
          {196, 0},
          {196, 4},
          {38, 6},
          {126, 7},
          {38, 8},
          {46, 10},
          {28, 11},
          {222, 12},
          {28, 13},
          {46, 14},
          {122, 17},
          {76, 21},
          {76, 23}
        ],
        pixel_map: [
          {{0, 0}, {200, 200}},
          {{800, 0}, {1000, 200}},
          {{200, 200}, {400, 400}},
          {{400, 200}, {600, 400}},
          {{600, 200}, {800, 400}},
          {{0, 400}, {200, 600}},
          {{200, 400}, {400, 600}},
          {{400, 400}, {600, 600}},
          {{600, 400}, {800, 600}},
          {{800, 400}, {1000, 600}},
          {{400, 600}, {600, 800}},
          {{200, 800}, {400, 1000}},
          {{600, 800}, {800, 1000}}
        ]
      }
  end
end
