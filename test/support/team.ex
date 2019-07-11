defmodule Team do
  use Ecto.Schema

  import Ecto.Rescope

  schema "teams" do
    field(:name, :string)
    field(:is_deleted, :boolean, default: false)

    has_many(:users, User)
  end

  rescope(&SoftDelete.exclude_deleted/1)
end
