defmodule Ecto.Rescope.TestRepo.Migrations.AddTestSchemas do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add(:name, :string, null: false)
      add(:is_deleted, :boolean, null: false, default: false)

      timestamps(default: fragment("now()"))
    end

    create table(:users) do
      add(:name, :string, null: false)
      add(:is_deleted, :boolean, null: false, default: false)
      add(:team_id, references(:teams, on_delete: :delete_all))

      timestamps(default: fragment("now()"))
    end
  end
end
