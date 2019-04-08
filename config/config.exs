use Mix.Config

config :activity_api,
  port: 4001

import_config "#{Mix.env()}.exs"
