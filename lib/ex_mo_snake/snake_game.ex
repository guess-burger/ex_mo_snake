defmodule ExMoSnake.SnakeGame do

  @size 23

  defmodule Game do
    defstruct is_over: false, snake1: nil, snake2: nil, pellet: nil
  end

  defmodule Snake do
    defstruct id: nil, dir_press: :none, dir: "right", points: nil, colour: nil

    def update_dir(%Snake{dir_press: :none} = state), do: state
    def update_dir(%Snake{dir_press: "left", dir: old} = state) when old != "right" do
      %Snake{ state | dir: "left"}
    end
    def update_dir(%Snake{dir_press: "right", dir: old} = state) when old != "left" do
      %Snake{ state | dir: "right"}
    end
    def update_dir(%Snake{dir_press: "up", dir: old} = state) when old != "down" do
      %Snake{ state | dir: "up"}
    end
    def update_dir(%Snake{dir_press: "down", dir: old} = state) when old != "up" do
      %Snake{ state | dir: "down"}
    end
    def update_dir(state), do: state

  end

  def new(player1, player2) do
    p1_points = :queue.from_list([{1, 5}, {2, 5}, {3, 5}])
    p1_snake = %Snake{id: player1, points:  p1_points, colour:  "red"}

    p2_points = :queue.from_list([{1, 19}, {2, 19}, {3, 19}])
    p2_snake = %Snake{id: player2, points: p2_points, colour: "blue"}

    new_pellet(%Game{snake1: p1_snake, snake2: p2_snake})
  end

  defp new_pellet(%Game{snake1: %Snake{points: snake1}, snake2:  %Snake{points: snake2}} = game) do
      # FIXME this function could be better. Issues with it are:
      # * players might take up the whole screen
      # * if players take a lot of space this function might run for a while
      potential_pellet = {:rand.uniform(@size), :rand.uniform(@size)}

      in_snake1? = :queue.member(potential_pellet, snake1)
      in_snake2? = :queue.member(potential_pellet, snake2)

      cond do
        in_snake1? -> new_pellet(game)
        in_snake2? -> new_pellet(game)
        true -> %Game{ game | pellet: potential_pellet}
      end
   end


  @draw_points BlockWrite.block_write('draw', 4, 8)
  def draw_points, do: @draw_points

  @win_points BlockWrite.block_write('win!', 3, 8)
  def win_points, do: @win_points

  @lose_points BlockWrite.block_write('lose', 3, 8)
  def lose_points, do: @lose_points

end