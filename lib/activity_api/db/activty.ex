defmodule ActivitiApi.Db.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activities" do
    field :user_email, :string
    field :activity_type, :string
    field :created_on, :date
  end

  @fields ~w(user_email activity_type created_on)a
  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:one_activity_on_day, name: :one_activity_on_day)
  end
end
