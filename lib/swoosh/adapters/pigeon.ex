defmodule Swoosh.Adapters.Pigeon do
  @moduledoc """
  Swoosh adapter that delivers through the Pigeon HTTP API.

      config :my_app, MyApp.Mailer,
        adapter: Swoosh.Adapters.Pigeon,
        api_key: System.get_env("PIGEON_API_KEY"),
        base_url: System.get_env("PIGEON_BASE_URL") || "http://localhost:4005"
  """

  @behaviour Swoosh.Adapter

  alias Pigeon.Client

  @impl true
  def validate_config(config) do
    Swoosh.Adapter.validate_config([:api_key], config)
  end

  @impl true
  def deliver(email, config) do
    api_key = Keyword.fetch!(config, :api_key)
    base_url = Keyword.get(config, :base_url, "http://localhost:4005")
    client = Client.new(api_key, base_url: base_url)

    attrs = %{
      "from" => format_from(email),
      "to" => addresses(email.to),
      "cc" => addresses(email.cc),
      "bcc" => addresses(email.bcc),
      "reply_to" => addresses(List.wrap(email.reply_to)),
      "subject" => email.subject,
      "html" => email.html_body,
      "text" => email.text_body
    }

    case Client.send_email(client, attrs) do
      {:ok, body} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  defp format_from(%{from: {name, address}}) when is_binary(name) and name != "",
    do: "#{name} <#{address}>"

  defp format_from(%{from: {_name, address}}), do: address
  defp format_from(%{from: address}) when is_binary(address), do: address

  defp addresses(nil), do: []
  defp addresses(list) when is_list(list) do
    Enum.map(list, fn
      {_, address} -> address
      address when is_binary(address) -> address
    end)
  end
end
