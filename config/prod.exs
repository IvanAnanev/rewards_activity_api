use Mix.Config

port =
  case System.get_env("PORT") do
    port when is_binary(port) -> String.to_integer(port)
    nil -> 80 # default port
  end

config :activity_api,
  port: port

config :activity_api, ActivityApi.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :activity_api,
  bots: %{
    "flatstack" => %{
      name: System.get_env("FLATSTACK_ACTIVITY_BOT"),
      password: System.get_env("FLATSTACK_ACTIVITY_BOT_PASSWORD"),
      message: "+:points to @:user_name #be-curious-never-stop-learning for :for_goal"
    }
  }

config :activity_api,
  rewards_url: System.get_env("REWARDS_URL")

