defmodule Pigeon.Client do
  @moduledoc """
  HTTP client for the Pigeon email API (`POST /api/emails` and related routes).
  """

  @default_base "http://localhost:4005"

  defstruct [:api_key, :base_url, :req]

  def new(api_key, opts \\ []) when is_binary(api_key) do
    base = Keyword.get(opts, :base_url, System.get_env("PIGEON_BASE_URL") || @default_base)

    %__MODULE__{
      api_key: api_key,
      base_url: String.trim_trailing(base, "/"),
      req: Keyword.get(opts, :req, Req)
    }
  end

  def send_email(%__MODULE__{} = client, attrs) when is_map(attrs) do
    request(client, :post, "/api/emails", json: stringify_keys(attrs))
  end

  def list_emails(%__MODULE__{} = client, query \\ []) do
    request(client, :get, "/api/emails", params: Map.new(query))
  end

  def get_email(%__MODULE__{} = client, id) do
    request(client, :get, "/api/emails/#{id}")
  end

  def cancel_email(%__MODULE__{} = client, id) do
    request(client, :post, "/api/emails/#{id}/cancel")
  end

  def list_domains(%__MODULE__{} = client) do
    request(client, :get, "/api/domains")
  end

  def create_domain(%__MODULE__{} = client, name) when is_binary(name) do
    request(client, :post, "/api/domains", json: %{name: name})
  end

  def verify_domain(%__MODULE__{} = client, id) do
    request(client, :post, "/api/domains/#{id}/verify")
  end

  def create_contact(%__MODULE__{} = client, attrs) do
    request(client, :post, "/api/contacts", json: stringify_keys(attrs))
  end

  def trigger_automation(%__MODULE__{} = client, id, attrs \\ %{}) do
    request(client, :post, "/api/automations/#{id}/trigger", json: stringify_keys(attrs))
  end

  defp request(client, method, path, opts \\ []) do
    url = client.base_url <> path

    req_opts =
      [url: url, method: method, auth: {:bearer, client.api_key}]
      |> Keyword.merge(opts)

    case client.req.request(req_opts) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        {:error, %{status: status, body: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp stringify_keys(map) do
    Map.new(map, fn {k, v} -> {to_string(k), v} end)
  end
end
