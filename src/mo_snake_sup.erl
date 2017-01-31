-module(mo_snake_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	Procs = [
		{lobby, {'Elixir.ExMoSnake.Lobby', start_link, []}, permanent, 5000, worker, ['Elixir.ExMoSnake.Lobby']}
	],

	{ok, {{one_for_one, 1, 5}, Procs}}.
