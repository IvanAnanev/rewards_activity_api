defmodule ActivityApi.RewardsApi do
  @headers  [{"Content-Type", "application/vnd.api+json"}, {"Accept", "application/vnd.api+json"}]
  @opts [{:pool, :default}]

  @bot_tokens "api/v1/bot/tokens"
  def bot_tokens(bot_name, password) do
    payload = Jason.encode! %{data: %{type: "bot-token-requests", attributes: %{name: bot_name, password: password}}}
    case :hackney.post(
      rewards_url() <> @bot_tokens,
      @headers,
      payload,
      @opts
    ) do
      {:ok, 201, _, client_ref} ->
        {:ok, body} = :hackney.body(client_ref)
        Jason.decode(body, keys: :atoms) |> IO.inspect()

      {:ok, 404, _, _} ->
        {:error, :not_found}

      {:ok, 401, _, _} ->
        {:error, :not_authorized}

      _ ->
        {:error, :something_wrong}
    end
  end

  # @user_tokens "api/v1/user/tokens"
  # def user_tokens(email, password) do
  #   payload = Jason.encode! %{data: %{type: "user-token-requests", attributes: %{email:  email, password: password}}}
  #   {:ok, _, _, client_ref} = :hackney.post(
  #     rewards_url() <> @user_tokens,
  #     @headers,
  #     payload,
  #     @opts
  #   )
  #   {:ok, body} = :hackney.body(client_ref)
  #   Jason.decode!(body, keys: :atoms)
  # end

  @user_profile "api/v1/user/profile"
  def user_profile(user_token) do
    case :hackney.get(
      rewards_url() <> @user_profile,
      [{"Authorization", user_token}|@headers],
      "",
      @opts
    )  do
      {:ok, 200, _, client_ref} ->
        {:ok, body} = :hackney.body(client_ref)
        Jason.decode(body, keys: :atoms)

      {:ok, 404, _, _} ->
        {:error, :not_found}

      {:ok, 401, _, _} ->
        {:error, :not_authorized}

      _ ->
        {:error, :something_wrong}
    end
  end

  @bot_bonuses "api/v1/bot/bonuses"
  def bot_bonuses(bot_token, bonus_text) do
    payload = Jason.encode! %{data: %{type: "bonus-texts", attributes: %{text: bonus_text}}}
    # {:ok, _, _, client_ref} = :hackney.post(
    #   rewards_url() <> @bot_bonuses,
    #   [{"Authorization", "Bearer #{bot_token}"}|@headers],
    #   payload,
    #   @opts
    # )
    # {:ok, body} = :hackney.body(client_ref)
    # Jason.decode!(body, keys: :atoms)
    case :hackney.post(
      rewards_url() <> @bot_bonuses,
      [{"Authorization", "Bearer #{bot_token}"}|@headers],
      payload,
      @opts
    ) do
      {:ok, 201, _, client_ref} ->
        {:ok, body} = :hackney.body(client_ref)
        Jason.decode(body, keys: :atoms)

      {:ok, 404, _, _} ->
        {:error, :not_found}

      {:ok, 401, _, _} ->
        {:error, :not_authorized}

      _ ->
        {:error, :something_wrong}
    end
  end


  defp rewards_url() do
    Application.get_env(:activity_api, :rewards_url)
  end
end