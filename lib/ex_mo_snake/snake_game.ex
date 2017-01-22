defmodule ExMoSnake.SnakeGame do

  defstruct is_over: false, snake1: nil, snake2: nil, pellet: nil


  defmodule ExMoSnake.SnakeGame.Snake do
    defstruct id: nil, dir_press: nil, dir: nil, points: nil, colour: nil
  end



  @draw_points BlockWrite.block_write('draw', 4, 8)
  def draw_points, do: @draw_points

  @win_points BlockWrite.block_write('win!', 3, 8)
  def win_points, do: @win_points

  @lose_points BlockWrite.block_write('lose', 3, 8)
  def lose_points, do: @lose_points

end