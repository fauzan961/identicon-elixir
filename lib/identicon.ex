defmodule Identicon do
  def main(input) do
    input |> hash_input |> pick_color |> build_grid |> filter_odd_squares |> build_pixel_map |> draw_image |> save_image(input)
  end

  def hash_input(input) do
   hex = :crypto.hash(:md5, input) |> :binary.bin_to_list  #Hashing our input string and converting it into a hashed list
   %Identicon.Image{hex: hex}
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]}   = image) do #Pattern matching our input image struct
  %Identicon.Image{image | color: {r,g,b}} #Creating a new struct by feeding our image with hex key and value and new color key and value
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
   grid = hex |> Enum.chunk_every(3, 3, :discard) #Converts our list into a list of list with each sublists having 3 elements inside it
    |> Enum.map(&mirror_row/1) # & syntax is used here to call our mirror_row function
    |> List.flatten  #Flattens/Converts nested list into a one dimensional simple list (Here list of list into a list)
    |> Enum.with_index #Converts every elements of our list into a two element tuple with first element of tuple as the value and second element as the index
    %Identicon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter(grid, fn({code, _index}) -> rem(code, 2) == 0  end) #Removing grids which have odd numbers
    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
   pixel_map =  Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50 }
      {top_left, bottom_right}
    end
    %Identicon.Image{image | pixel_map: pixel_map}

  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250,250) #Create our rectangle of 250 x 250 (width x height)
    fill = :egd.color(color) # Fill variable which stores the RGB value of our color

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)  # Creates our identicon on the rectangle by feeding start and end coordinates and the color
    end
    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end
