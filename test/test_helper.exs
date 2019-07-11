{:ok, _} = Application.ensure_all_started(:ecto_sql)

ExUnit.start()

Supervisor.start_link([{Ecto.Rescope.TestRepo, []}],
  strategy: :one_for_one,
  name: Ecto.Rescope.TestRepoSupervisor
)

Ecto.Adapters.SQL.Sandbox.mode(Ecto.Rescope.TestRepo, :manual)
