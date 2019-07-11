use Mix.Config

config :logger,
  level: :warn,
  handle_otp_reports: true

# Configure your database
config :ecto_rescope, Ecto.Rescope.TestRepo,
  username: "postgres",
  password: "postgres",
  database: "ecto_rescope_test",
  port: System.get_env("DATABASE_PORT") || 5432,
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :ecto_rescope, ecto_repos: [Ecto.Rescope.TestRepo]
