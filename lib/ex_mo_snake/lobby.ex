defmodule ExMoSnake.Lobby do
  use GenServer
  alias __MODULE__
  alias ExMoSnake.Match

  defstruct waiting: nil, games: []


  def start_link(), do: GenServer.start_link(Lobby, [], name: __MODULE__)


  def register(), do: GenServer.cast(Lobby, {:register, self} )


  def leave(pid), do: GenServer.cast(Lobby, {:leave_lobby, pid})



  def init([]) do
    IO.puts "lobby init"
    {:ok, %Lobby{}}
  end


  def handle_cast({:register, player1}, %Lobby{waiting: :nil}=state) do
    IO.puts "Player1 registered #{inspect player1}"
    {:noreply, %Lobby{state| waiting: player1}}
  end
  def handle_cast({:register, player2}, %Lobby{waiting: player1, games: games}=state) do
    {:ok, game} = Match.start(player1, player2)
    IO.puts "Player2 registered #{inspect player2}; starting match #{inspect game}"
    {:noreply, %Lobby{state| waiting: :nil, games: [game | games]}}
  end
  def handle_cast({:leave_lobby, user_pid}, state) do
    {:noreply, leave_lobby(user_pid, state)}
  end


  defp leave_lobby(user_pid, %Lobby{waiting: user_pid}=state) do
    %Lobby{state| waiting: :nil}
  end
  defp leave_lobby(user_pid, %Lobby{waiting: user_pid}=state) do
    state
  end
  
end
