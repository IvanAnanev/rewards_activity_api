defmodule ActivityApi.Repo.Migrations.AddActivitiesTable do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :user_email, :string
      add :activity_type, :string
      add :created_on, :date
    end

    create unique_index(:activities, [:user_email, :activity_type, :created_on], name: :one_activity_on_day)
    create index(:activities, [:user_email, :created_on])
  end
end
