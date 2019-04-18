use Mix.Config

config :activity_api,
  port: 4001

config :activity_api,
  ecto_repos: [ActivityApi.Repo]

config :activity_api,
  bots: %{
    "flatstack" => %{
      name: "activity",
      password: "123456",
      message: "+:points to @:user_name #be-curious-never-stop-learning for :for_goal"
    }
  }



import_config "#{Mix.env()}.exs"
