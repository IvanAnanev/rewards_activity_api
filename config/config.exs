use Mix.Config

config :activity_api,
  port: 4001

config :activity_api,
  ecto_repos: [ActivityApi.Repo]

import_config "#{Mix.env()}.exs"
