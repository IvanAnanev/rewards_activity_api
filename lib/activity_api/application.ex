defmodule ActivityApi.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [
        Plug.Cowboy.child_spec(
          scheme: :http,
          plug: nil,
          options: [
            port: Application.get_env(:activity_api, :port, 4000),
            dispatch: dispatch()
          ]
        )
      ],
      strategy: :one_for_one,
      name: Server.Application
    )
  end

  defp dispatch() do
    [
      {:_,
       [
         {:_, Plug.Cowboy.Handler, {ActivityApi.Endpoint, []}}
       ]}
    ]
  end
end
