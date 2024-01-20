defmodule Identicon do
  @moduledoc """
    Providers methods to generate identicon image
  """

  @doc """
    Takes string input and return an identicon image at parent folder
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
    Create Image struct with hexes number

  ## Example

        iex> Identicon.hash_input("adi")
        %Identicon.Image{
          hex: [196, 99, 53, 235, 38, 126, 46, 28, 222, 91, 1, 122, 203, 76, 215, 153],
          color: nil,
          grid: nil,
          pixel_map: nil
        }
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
    Generate RGB color from the Image hex

  ## Example

        iex> result = Identicon.hash_input("adi")
        iex> Identicon.pick_color(result)
        %Identicon.Image{
          hex: [196, 99, 53, 235, 38, 126, 46, 28, 222, 91, 1, 122, 203, 76, 215, 153],
          color: {196, 99, 53},
          grid: nil,
          pixel_map: nil
        }
  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
    Generate grid for the image

  ## Example

        iex> result = Identicon.hash_input("adi")
        iex> Identicon.pick_color(result)
        iex> Identicon.build_grid(result)
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
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid = hex
    |> Enum.chunk_every(3)
    |> List.delete_at(-1)
    |> Enum.map(&mirror_row/1)
    |> List.flatten
    |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    [first, second | _tail] = row

    row ++ [second, first]
  end

  @doc """
    Delete the the grid with odd hex number

  ## Example

        iex> result = Identicon.hash_input("adi")
        iex> Identicon.pick_color(result)
        iex> result = Identicon.build_grid(result)
        iex> Identicon.filter_odd_squares(result)
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
  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Generate pixel map to be used for egd library

  ## Example

        iex> result = Identicon.hash_input("adi")
        iex> Identicon.pick_color(result)
        iex> result = Identicon.build_grid(result)
        iex> result = Identicon.filter_odd_squares(result)
        iex> Identicon.build_pixel_map(result)
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
  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn ({_code, index}) ->
      horizontal = rem(index, 5) * 200
      vertical = div(index, 5) * 200

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 200, vertical + 200}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
    Takes the Image struct and return the identicon image
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(1000, 1000)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  @doc """
    Saves the identicon image into png image inside parent folder
  """
  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

end
