defmodule User do
  use Ecto.Schema

  import Ecto.Rescope

  schema "users" do
    field(:name, :string)
    field(:is_deleted, :boolean, default: false)

    belongs_to(:team, Team)
  end

  rescope(&SoftDelete.exclude_deleted/1)
end
