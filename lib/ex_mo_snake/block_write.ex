defmodule BlockWrite do

  # I did origingally intend for this to be a macro
  # However, using attributes in modules allows us to pre-compute values anyway
  # which was the original intention for the macro

  def block_write(text, x, y) do
    IO.puts "Block Writing #{text}"
    block_write(text, x, y, [])
  end


  defp block_write([], _x, _y, acc) do
    List.flatten(acc)
  end
  defp block_write([letter | letters], x, y, acc) do
    {width, shape} = letter(letter)
    blocks = for {sx, sy} <- shape, do: {sx+x, sy+y}
    block_write(letters, x+width+1, y, Enum.concat(acc, blocks))
  end

  # Thanks to http://www.dafont.com/pixeltext.font?text=Win+Lose+Draw
  # FIXME these should probs be index by 0 and also in the shape of the letter
  defp letter(?a)  do
      {3,[
        {1, 5}, {1, 4}, {1, 3}, {1, 2},
        {2, 3}, {2, 1},
        {3, 5}, {3, 4}, {3, 3}, {3, 2}
      ]}
    end
  defp letter(?d)  do
    {3,[
      {1, 1}, {1, 2}, {1, 3}, {1, 4}, {1, 5},
      {2, 1}, {2, 5},
      {3, 2}, {3, 3}, {3, 4},
    ]}
  end
  defp letter(?e)  do
    {3,[
      {1, 5}, {1, 4}, {1, 3}, {1, 2}, {1, 1},
      {2, 5}, {2, 3}, {2, 1},
      {3, 5}, {3, 3}, {3, 1}
    ]}
  end
  defp letter(?i)  do
    {3,[
      {1, 1}, {1, 5},
      {2, 1}, {2, 2}, {2, 3}, {2, 4}, {2, 5},
      {3, 1}, {3, 5},
    ]}
  end
  defp letter(?l)  do
    {3,[
      {1, 5}, {1, 4}, {1, 3}, {1, 2}, {1, 1},
      {2, 5},
      {3, 5},
    ]}
  end
  defp letter(?n)  do
    {5,[
      {1, 1}, {1, 2}, {1, 3}, {1, 4}, {1, 5},
      {2, 2},
      {3, 3},
      {4, 4},
      {5, 1}, {5, 2}, {5, 3}, {5, 4}, {5, 5},
    ]}
  end
  defp letter(?o)  do
    {3,[
      {1, 4}, {1, 3}, {1, 2},
      {2, 5}, {2, 1},
      {3, 4}, {3, 3}, {3, 2},
    ]}
  end
  defp letter(?r)  do
    {3,[
      {1, 1}, {1, 2}, {1, 3}, {1, 4}, {1, 5},
      {2, 4}, {2, 3}, {2, 1},
      {3, 5}, {3, 3}, {3, 2}
    ]}
  end
  defp letter(?s)  do
    {3,[
      {1, 5}, {1, 3}, {1, 2}, {1, 1},
      {2, 5}, {2, 3}, {2, 1},
      {3, 5}, {3, 4}, {3, 3}, {3, 1},
    ]}
  end
  defp letter(?w)  do
    {3,[
      {1, 5}, {1, 4}, {1, 3}, {1, 2}, {1, 1},
      {2, 4},
      {3, 5}, {3, 4}, {3, 3}, {3, 2}, {3, 1}
    ]}
  end
  defp letter(?!) do
    {1,[
      {1, 1}, {1, 2}, {1, 3}, {1, 5}
    ]}
  end

end

