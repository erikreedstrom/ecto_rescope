defmodule User do
  use Ecto.Schema
  use Ecto.Rescope

  @rescope &SoftDelete.exclude_deleted/1
  schema "users" do
    field(:name, :string)
    field(:is_deleted, :boolean, default: false)

    belongs_to(:team, Team)
  end
end
