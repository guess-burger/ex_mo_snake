defmodule ExMoSnake.SnakeGame do
  alias ExMoSnake.SnakeGame, as: Game

  @size 23

  defstruct is_over: false, snake1: nil, snake2: nil, pellet: nil

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


  # FIXME be careful with this as I'm not sure if elixir will rebind the args in the function params
  def set_dir(%Game{snake1: %Snake{id: snake_id} = snake1} = state, snake_id, dir) do
    %Game{ state| snake1: %Snake{ snake1| dir_press: dir }};
  end
  def set_dir(%Game{snake2: %Snake{id: snake_id} = snake2} = state, snake_id, dir) do
    %Game{ state| snake2: %Snake{snake2| dir_press: dir}}
  end

  def step(%Game{snake1: snake1, snake2: snake2, pellet: pellet} = game) do

    # really need the pellets to be visible in the snake so that
    # all is fair
    # that means pellets need to be smaller than the snake blocks


    {head1, crash_self1, %Snake{points: snake_q1}=snake1} = Snake.step_snake(snake1)
    {head2, crash_self2, %Snake{points: snake_q2}=snake2} = Snake.step_snake(snake2)

    game =
      case pellet do
        ^head1 ->
          with_pellet = %Snake{snake1| points: :queue.in(Pellet, SnakeQ1)}
          new_pellet(%Game{game| snake1: with_pellet, snake2: snake2})
        ^head2 ->
          with_pellet = %Snake{snake2| points: :queue.in(Pellet, SnakeQ2)}
          new_pellet(%Game{game| snake1: snake1, snake2: with_pellet})
        _ ->
          %Game{game| snake1: snake1, snake2: snake2}
      end

    crash1 = :queue.member(head1, snake_q2)
    crash2 = :queue.member(head2, snake_q1)

    case {crash1 or crash_self1, crash2 or crash_self2} do
      {true, true} ->
        IO.puts "Draw #{:queue.to_list(snake_q1)} #{:queue.to_list(snake_q2)}"
        %Game{game| is_over: {true, :draw}}
      {true, false} ->
        IO.puts "P2 Win"
        %Game{game| is_over: {true, snake2.id}}
      {false, true} ->
        IO.puts "P1 Win"
        %Game{game| is_over: {true, snake1.id}}
      _no_crashes ->
        game
    end
  end


  @draw_points BlockWrite.block_write('draw', 4, 8)
  def draw_points, do: @draw_points

  @win_points BlockWrite.block_write('win!', 3, 8)
  def win_points, do: @win_points

  @lose_points BlockWrite.block_write('lose', 3, 8)
  def lose_points, do: @lose_points

end
