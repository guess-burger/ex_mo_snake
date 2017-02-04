defmodule ExMoSnake.Websocket do
  alias ExMoSnake.{Websocket, SnakeGame, Lobby, Match}
  defstruct [:match, :match_ref]

  def init(_, _req, _opts), do: {:upgrade, :protocol, :cowboy_websocket}


  def websocket_init(_type, req, _opts) do
    IO.puts "Websocket init"
    ExMoSnake.Lobby.register()
    {:ok, req, %Websocket{}}
  end


  # Handles erlang messages
  def websocket_info({:update, game}, req, state) do
    {:reply, [
      {:text, SnakeGame.to_json(game)}
    ], req, state}
  end
  def websocket_info({:match_start, match}, req, _state) do
    ref = Process.monitor(match)
    {:ok, req, %Websocket{match: match, match_ref: ref}}
  end
  def websocket_info(:join_lobby, req, state) do
    Lobby.register()
    {:ok, req, state}
  end
  def websocket_info({:DOWN,match_ref,_,match,_}, req, %Websocket{match: match, match_ref: match_ref}) do
    # this is the case where the match just crashes for whatever reason
    # we don' match on this when the match is over since the match becomes undefined not the pid!
    IO.puts "Match down"
    Lobby.register()
    {:ok, req, %Websocket{}}
  end
  def websocket_info({:gameover, game}, req, state) do
    :erlang.send_after(5000, self, :join_lobby)
    # FIXME this seems too leaky. websocket_handler shouldn't need to know how to interact with a game
    json =
      case SnakeGame.result(game, self) do
        :draw -> SnakeGame.draw_json(game)
        :lose -> SnakeGame.lose_json(game)
        :win -> SnakeGame.win_json(game)
      end
    {:reply, {:text, json}, req, %Websocket{state| match: nil}}
  end
  def websocket_info(msg, req, state) do
    IO.puts "Got Unknown #{inspect msg} #{inspect req}"
    {:ok, :req, state}
  end


  # other frame types are text, binary, ping, pong
  def websocket_handle({:text, msg}, req, %Websocket{ match: match }=state) when match != nil do
    move = :jsx.decode(msg)
    IO.puts "Got msg: #{inspect move}"
    Match.move(move, match)
    {:ok, req, state}
  end
  def websocket_handle(_frame, req, state) do
    {:ok, req, state}
  end



  def websocket_terminate(_reason, _req, %Websocket{match: nil}) do
    # We're waiting in the lobby!
    Lobby.leave(self)
    :ok
  end
  def websocket_terminate(_reason, _req, %Websocket{match: match}) do
    IO.puts "Websocket terminated"
    Match.leave(match)
    :ok
  end


  def terminate(_Reason, _Req, _State), do: :ok

end
