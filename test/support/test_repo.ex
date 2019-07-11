defmodule Ecto.Rescope.TestRepo do
  use Ecto.Repo, otp_app: :ecto_rescope, adapter: Ecto.Adapters.Postgres
end
