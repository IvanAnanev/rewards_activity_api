defmodule ActivityApi.Repo do
  use Ecto.Repo,
    otp_app: :activity_api,
    adapter: Ecto.Adapters.Postgres
end
