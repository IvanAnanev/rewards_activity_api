defmodule ActivityApi.Activities do
  @moduledoc """
  The Activities context.
  """
  import Ecto.Query, warn: false
  alias ActivityApi.Repo
  alias ActivitiApi.Db.Activity

  def create_activity(attrs \\ %{}) do
    %Activity{}
    |> Activity.changeset(attrs)
    |> Repo.insert()
  end

  def list_activity() do
    Repo.all(Activity)
  end

  def claimed_goals(user_email, date) do
    query = from a in Activity,
      where: a.user_email == ^user_email and a.created_on == ^date,
      select: a.activity_type

    Repo.all(query)
  end

  def metrics, do: ~w(stand move excercise)

  def requirements(user_email, date) do
    claimed_goals = claimed_goals(user_email, date)

    requirements = Enum.map(metrics(), fn activity ->
      %{metric: activity, has_claimed: Enum.member?(claimed_goals, activity)}
    end)
  end
end
