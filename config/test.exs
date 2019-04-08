use Mix.Config

# Configure your database
config :activity_api, ActivityApi.Repo,
  # username: "postgres",
  # password: "postgres",
  database: "activity_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
