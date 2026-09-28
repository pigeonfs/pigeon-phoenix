# Pigeon Phoenix adapter

HTTP client (`Pigeon.Client`) and [Swoosh](https://github.com/swoosh/swoosh) adapter (`Swoosh.Adapters.Pigeon`) for apps that send through Pigeon instead of SES/SMTP directly.

## Mix

```elixir
def deps do
  [{:pigeon_client, github: "pigeonfs/pigeon-phoenix"}]
end
```

## Swoosh mailer

```elixir
config :my_app, MyApp.Mailer,
  adapter: Swoosh.Adapters.Pigeon,
  api_key: System.get_env("PIGEON_API_KEY"),
  base_url: System.get_env("PIGEON_BASE_URL") || "http://localhost:4005"
```

```elixir
import Swoosh.Email

new()
|> from({"Ada", "ada@yourdomain.com"})
|> to("person@example.com")
|> subject("Hello")
|> html_body("<p>Hello</p>")
|> MyApp.Mailer.deliver()
```

## HTTP client

```elixir
client = Pigeon.Client.new("pg_xxxx")

{:ok, email} =
  Pigeon.Client.send_email(client, %{
    from: "Ada <ada@yourdomain.com>",
    to: ["person@example.com"],
    subject: "Hello",
    html: "<p>Hello</p>"
  })
```

Uses `Req`. The from address must be on a verified Pigeon domain.

## License

MIT
