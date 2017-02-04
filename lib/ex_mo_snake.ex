defmodule ExMoSnake do

    def start(_type, _args) do
        {:ok, _} = :mo_snake_sup.start_link()
        dispatch = :cowboy_router.compile([
            # {HostMatch, list({PathMatch, Handler, Opts})}
            {:_, [
              {'/', :cowboy_static, {:file, 'priv/static/index.html'}},
              {'/resources/[...]', :cowboy_static, {:priv_dir, ExMoSnake, 'static'}},
              {'/echo', ExMoSnake.Websocket, []}
            ]}
        ])
        # Name, NbAcceptors, TransOpts, ProtoOpts
        :cowboy.start_http(:my_http_listener, 100,
            [{:port, 8080}],
            [{:env, [{:dispatch, dispatch}]}]
        )
    end

    def stop(_state), do: :ok

end
