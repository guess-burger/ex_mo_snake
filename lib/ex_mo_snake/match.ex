defmodule ExMoSnake.Match do
  use GenServer
  alias ExMoSnake.SnakeGame

  defmodule InitState do
    defstruct [:player1, :player2]
  end

  defmodule PlayingState do
    defstruct [:player1, :player2, :game, :timer_ref]
  end


  def start(player1, player2), do: GenServer.start(__MODULE__, {player1, player2}, [])


  def move(dir, game), do: GenServer.cast(game, {:move, self, dir})


  def leave(game), do: GenServer.cast(game, {:player_left, self})



  def init({player1, player2}) do
    send(player1, {:match_start, self})
    send(player2, {:match_start, self})
    :erlang.send(self, :tick)
    IO.puts "Match init"
    {:ok, %InitState{player1: player1, player2: player2}}
  end


  def handle_cast({:player_left, player_pid}, state) do
    state = player_left(player_pid, state)
    {:stop, :normal, state}
  end
  def handle_cast({:move, player, dir}, %PlayingState{ game: game }=state) do
    game = SnakeGame.set_dir(game, player, dir)
    {:noreply, %PlayingState{state| game: game}}
  end


  def handle_info(:tick, %InitState{player1: p1, player2: p2}) do
    game = SnakeGame.new(p1,p2)
    {:ok, time_ref} = :timer.send_interval(500, :tick)
    IO.puts "Match start"
    {:noreply, %PlayingState{player1: p1, player2:  p2, game: game, timer_ref: time_ref}}
  end
  def handle_info(:tick, %PlayingState{game: game}=state) do
    game = SnakeGame.step(game)
    if SnakeGame.is_over(game) do
      send(state.player2, {:gameover, game})
      send(state.player1, {:gameover, game})
      {:stop, :normal, game}
    else
      send(state.player1, {:update, game})
      send(state.player2, {:update, game})
      {:noreply, %PlayingState{state| game: game}}
    end
  end


  defp player_left(player_pid, %InitState{player1: p1, player2: p2}=state) do
    player_left(p1, p2, player_pid, SnakeGame.new(p1, p2))
    state
  end
  defp player_left(player_pid, %PlayingState{player1: p1, player2: p2, game: game}=state) do
    player_left(p1, p2, player_pid, game)
    state
  end

  defp player_left(p1, p2, player_left, game) when p1 == player_left do
    IO.puts "Player 1 #{inspect player_left} has left the match"
    game = SnakeGame.force_winner(p2, game)
    send(p2, {:gameover, game})
  end
  defp player_left(p1, p2, player_left, game) when p2 == player_left do
    IO.puts "Player 2 #{inspect player_left} has left the match"
    game = SnakeGame.force_winner(p1, game)
    send(p1, {:gameover, game})
  end

end
