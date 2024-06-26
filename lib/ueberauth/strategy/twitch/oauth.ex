defmodule Ueberauth.Strategy.Twitch.OAuth do
  @moduledoc """
  An implementation of OAuth2 for twitch.

  To add your `client_id` and `client_secret` include these values in your configuration.

      config :ueberauth, Ueberauth.Strategy.Twitch.OAuth,
        client_id: System.get_env("TWITCH_CLIENT_ID"),
        client_secret: System.get_env("TWITCH_CLIENT_SECRET")
  """
  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    site: "https://twitch.tv",
    authorize_url: "https://id.twitch.tv/oauth2/authorize",
    token_url: "https://id.twitch.tv/oauth2/token",
    token_method: :post
  ]

  @doc """
  Construct a client for requests to Twitch.

  Optionally include any OAuth2 options here to be merged with the defaults.

      Ueberauth.Strategy.Twitch.OAuth.client(redirect_uri: "http://localhost:4000/auth/twitch/callback")

  This will be setup automatically for you in `Ueberauth.Strategy.Twitch`.
  These options are only useful for usage outside the normal callback phase of Ueberauth.
  """
  def client(opts \\ []) do
    config =
      :ueberauth
      |> Application.fetch_env!(Ueberauth.Strategy.Twitch.OAuth)
      |> check_config_key_exists(:client_id)
      |> check_config_key_exists(:client_secret)

    client_opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    json_library = Ueberauth.json_library()

    OAuth2.Client.new(client_opts)
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth. No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get(token, url, headers \\ [{"Client-ID", client().client_id}], opts \\ []) do
    [token: token]
    |> client
    |> put_param("access_token", token)
    |> OAuth2.Client.get(url, headers, opts)
  end

  def get_token(params \\ [], options \\ []) do
    headers = Keyword.get(options, :headers, [])
    options = Keyword.get(options, :options, [])
    client_options = Keyword.get(options, :client_options, [])
    case OAuth2.Client.get_token(client(client_options), params, headers, options) do
      {:ok, client} ->
        {:ok, client.token}
      {:error, %OAuth2.Response{} = response} ->
        {:error, response.body}
    end
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    client
    |> put_param("response_type", "code")
    |> put_param("redirect_uri", client().redirect_uri)

    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param("client_id", client().client_id)
    |> put_param("client_secret", client().client_secret)
    |> put_param("grant_type", "authorization_code")
    |> put_param("redirect_uri", client().redirect_uri)
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

  defp check_config_key_exists(config, key) when is_list(config) do
    unless Keyword.has_key?(config, key) do
      raise "#{inspect(key)} missing from config :ueberauth, Ueberauth.Strategy.Twitch"
    end

    config
  end

  defp check_config_key_exists(_, _) do
    raise "Config :ueberauth, Ueberauth.Strategy.Twitch is not a keyword list, as expected"
  end
end
