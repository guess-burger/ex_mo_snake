defmodule ExMoSnake.SnakeGame do
  alias ExMoSnake.SnakeGame, as: Game

  @size 23

  defstruct is_over: false, snake1: nil, snake2: nil, pellet: nil

  defmodule Snake do
    @up "Up"
    @down "Down"
    @left "Left"
    @right "Right"

    defstruct id: nil, dir_press: :none, dir: @right, points: nil, colour: nil

    def step(snake, size) do
      %Snake{points: points, dir: dir} = snake = update_dir(snake)
      head = :queue.get_r(points)
      head = newHead(head, dir, size)

      moved = :queue.drop(points)
      crash_self = :queue.member(head, moved)
      snake = %Snake{snake| points: :queue.in(head, moved), dir_press: "none"}
      {head, crash_self, snake}
      end



    defp update_dir(%Snake{dir_press: :none} = snake) do
      snake
    end
    defp update_dir(%Snake{dir_press: @left, dir: old} = snake) when old != @right do
      %Snake{ snake | dir: @left}
    end
    defp update_dir(%Snake{dir_press: @right, dir: old} = snake) when old != @left do
      %Snake{ snake | dir: @right}
    end
    defp update_dir(%Snake{dir_press: @up, dir: old} = snake) when old != @down do
      %Snake{ snake | dir: @up}
    end
    defp update_dir(%Snake{dir_press: @down, dir: old} = snake) when old != @up do
      %Snake{ snake | dir: @down}
    end
    defp update_dir(snake) do
      snake
    end

    # FIXME there must be a better way of doing this! Just add then mod!
    defp newHead({size, y}, @right, size), do: {1, y}
    defp newHead({x, y}, @right, _size), do: {x + 1, y}
    defp newHead({1, y}, @left, size), do: {size, y}
    defp newHead({x, y}, @left, _size), do: {x - 1, y}
    defp newHead({x, 1}, @up, size), do: {x, size}
    defp newHead({x, y}, @up, _size), do: {x, y - 1}
    defp newHead({x, size}, @down, size), do: {x, 1}
    defp newHead({x, y}, @down, _size), do: {x, y + 1}
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

    {head1, crash_self1, %Snake{points: snake_q1}=snake1} = Snake.step(snake1, @size)
    {head2, crash_self2, %Snake{points: snake_q2}=snake2} = Snake.step(snake2, @size)

    game =
      case pellet do
        ^head1 ->
          with_pellet = %Snake{snake1| points: :queue.in(pellet, snake_q1)}
          new_pellet(%Game{game| snake1: with_pellet, snake2: snake2})
        ^head2 ->
          with_pellet = %Snake{snake2| points: :queue.in(pellet, snake_q2)}
          new_pellet(%Game{game| snake1: snake1, snake2: with_pellet})
        _ ->
          %Game{game| snake1: snake1, snake2: snake2}
      end

    crash1 = :queue.member(head1, snake_q2)
    crash2 = :queue.member(head2, snake_q1)

    case {crash1 or crash_self1, crash2 or crash_self2} do
      {true, true} ->
        IO.puts "Draw #{inspect :queue.to_list(snake_q1)} #{inspect :queue.to_list(snake_q2)}"
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


  def force_winner(winner, game), do: %Game{game| is_over: {true, winner}}


  def is_over(%Game{is_over: false}), do: false
  def is_over(%Game{is_over: {true, _}}), do: true


  def result(%Game{is_over: false}, _Player) do
    :not_over
  end
  def result(%Game{is_over: {true, result}}, player) do
    case result do
      :draw -> :draw;
      ^player -> :win;
      _other_player -> :lose
    end
  end


  def to_json(%Game{snake1: snake1, snake2: snake2, pellet: pellet}) do
    pellet_json = make_snake(points_to_json([pellet]), "black")
    json_snakes = [snake_to_json(snake1), snake_to_json(snake2), pellet_json]
    :jsx.encode([{"snakes", json_snakes}])
  end

  defp snake_to_json(%Snake{points: points, colour: colour}) do
    json_points = points_to_json(:queue.to_list(points))
    make_snake(json_points, colour)
  end

  defp make_snake(points, colour), do: [{"points", points}, {"colour", colour}]

  defp points_to_json(points), do: for {x, y} <- points, do: [{"x", x}, {"y", y}]

  @win_points BlockWrite.block_write('win!', 4, 8)
  def win_json(game), do: end_blocks(game, @win_points)

  @lose_points BlockWrite.block_write('lose', 3, 8)
  def lose_json(game), do: end_blocks(game, @lose_points)

  @draw_points BlockWrite.block_write('draw', 4, 8)
  def draw_json(game), do: end_blocks(game, @draw_points)

  defp end_blocks(%Game{snake1: snake1, snake2: snake2}, text) do
    text_snake = make_snake(points_to_json(text), "black")
    json_snakes = [snake_to_json(snake1), snake_to_json(snake2)]
    :jsx.encode([{"snakes", [text_snake | json_snakes]}])
  end

end
