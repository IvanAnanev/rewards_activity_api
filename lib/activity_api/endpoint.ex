defmodule ActivityApi.Endpoint do
  use Plug.Router
  alias ActivityApi.{Activities, RewardsApi}

  plug :match
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug :dispatch

  get "/ping" do
    Plug.Conn.get_req_header(conn, "authorization") |> IO.inspect()

    send_resp(conn, 200, "pong")
  end

  get "/activity_requirements" do
    conn
    |> get_user_token()
    |> take_user()
    |> take_requirements()
    |> response_activity_requiremaents(conn)
  end

  post "/claim_bonus_points" do
    conn
    |> get_user_token()
    |> take_user()
    |> validate_params(conn)
    |> check_goal_claimed()
    |> take_bot_token()
    |> make_bonuses()
    |> response_claim_bonus_points(conn)
  end

  # Default fallback for unrecognized routes
  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp get_user_token(conn) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      [token|[]] -> {:ok, token}
      _ -> {:error, :token_expected}
    end
  end

  defp take_user({:error, _} = e), do: e
  defp take_user({:ok, token}) do
    case RewardsApi.user_profile(token) do
      #TODO: в этом месте должна ещё прийти информация о компании и таймзоне пользователя
      {:ok, %{data: %{attributes: %{email: user_email, username: user_name}}}} ->
        {:ok, user_email, user_name}

      {:error, _} = e -> e
      _ -> {:error, :something_wrong}
    end
  end

  # TODO: здесь еще необходима таймзона пользователя
  @goal 200
  defp take_requirements({:error, _} = e), do: e
  defp take_requirements({:ok, user_email, _}) do
    data = Activities.requirements(user_email, date_now())
      |> Enum.with_index(1)
      |> Enum.map(fn {el, index} ->
        %{
          type: "activity_requirements",
          id: index,
          attributes: Map.put(el, :goal, @goal)
        }
      end)

    {:ok, %{data: data}}
  end

  defp response_activity_requiremaents({:error, :token_expected}, conn) do
    send_resp(conn, 401, Jason.encode!(%{errors: %{tittle: "Unauthorized", detail: "Token expected"}}))
  end

  defp response_activity_requiremaents({:error, :not_authorized}, conn) do
    send_resp(conn, 401, Jason.encode!(%{errors: %{tittle: "Unauthorized", detail: "Token not authorized"}}))
  end

  defp response_activity_requiremaents({:error, :not_found}, conn) do
    send_resp(conn, 404, Jason.encode!(%{errors: %{tittle: "Api not found", detail: "Api user profile not found"}}))
  end

  defp response_activity_requiremaents({:error, :something_wrong}, conn) do
    send_resp(conn, 500, Jason.encode!(%{errors: %{tittle: "Something wrong", detail: "Something wrong"}}))
  end

  defp response_activity_requiremaents({:ok, response}, conn) do
    send_resp(conn, 200, Jason.encode!(response))
  end

  defp validate_params({:error, _} = e, _conn), do: e
  defp validate_params({:ok, user_email, user_name}, conn) do
    case conn.body_params do
      %{"metric" => metric, "value" => value} ->
        if Enum.member?(Activities.metrics(), metric) and value >= @goal do
          {:ok, user_email, user_name, metric, value}
        else
          {:error, :unvalid_params}
        end

      _ ->
        {:error, :unvalid_params}
    end
  end

  # TODO: нужна тайм зона
  defp check_goal_claimed({:error, _} = e), do: e
  defp check_goal_claimed({:ok, user_email, _, metric, _} = ok) do
    if Enum.member?(Activities.claimed_goals(user_email, date_now()), metric) do
      {:error, :already_claimed}
    else
      ok
    end
  end

  # TODO: пересмотреть для ботов к отдельным компаниям
  defp take_bot_token({:error, _} = e), do: e
  defp take_bot_token({:ok, user_email, user_name, metric, value}) do
    %{name: bot_name, password: bot_password, message: message_template} = Application.get_env(:activity_api, :bots)["flatstack"]
    bot_name |> IO.inspect()
    case RewardsApi.bot_tokens(bot_name, bot_password) do
      {:ok, %{data: %{id: bot_token}}} -> {:ok, user_email, user_name, metric, value, bot_token, message_template}
      {:error, _} = e -> e
      _ -> {:error, :something_wrong}
    end
  end

  # TODO: формат сообщения и количество бонусов
  @points "1"
  defp make_bonuses({:error, _} = e), do: e
  defp make_bonuses({:ok, user_email, user_name, metric, value, bot_token, message_template}) do
    message = message_template
    |> String.replace(":points", @points)
    |> String.replace(":user_name", user_name)
    |> String.replace(":for_goal", metric)
    |> IO.inspect()
    case RewardsApi.bot_bonuses(bot_token, message) do
      {:ok, _} ->
        Activities.create_activity(%{user_email: user_email, activity_type: metric, created_on: date_now()})
        {:ok, user_email, metric}
      {:error, _} = e -> e
      _ -> {:error, :something_wrong}
    end
  end

  # TODO: уточнить требуемые статусы
  defp response_claim_bonus_points({:error, :unvalid_params}, conn) do
    send_resp(conn, 422, Jason.encode!(%{errors: %{tittle: "Unvalid params", detail: "Unvalid params"}}))
  end

  defp response_claim_bonus_points({:error, :already_claimed}, conn) do
    send_resp(conn, 422, Jason.encode!(%{errors: %{tittle: "Unproccessable entity", detail: "Already claimed"}}))
  end

  defp response_claim_bonus_points({:error, :not_authorized}, conn) do
    send_resp(conn, 401, Jason.encode!(%{errors: %{tittle: "Unproccessable entity", detail: "bot bot authorized"}}))
  end

  defp response_claim_bonus_points({:error, :something_wrong}, conn) do
    send_resp(conn, 500, Jason.encode!(%{errors: %{tittle: "Something wrong", detail: "Something wrong"}}))
  end

  # TODO: уточнить положителный ответ
  defp response_claim_bonus_points({:ok, user_email, metric}, conn) do
    send_resp(conn, 200, Jason.encode!(%{data: "bonus for user #{user_email} for goal #{metric} was claimed"}))
  end

  defp date_now(timezone \\ "Europe/Moscow") do
    timezone |> Timex.now() |> DateTime.to_date()
  end
end
