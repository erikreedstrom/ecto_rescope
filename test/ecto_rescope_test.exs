defmodule Ecto.RescopeTest do
  use Ecto.Rescope.DataCase

  describe "rescope/1" do
    setup :test_data

    test "overrides default query", %{alice: alice, bob: bob, charlie: charlie} do
      users = TestRepo.all(User)
      assert Enum.member?(users, alice)
      refute Enum.member?(users, bob)
      assert Enum.member?(users, charlie)
    end

    test "relationships are scoped", %{blue: blue, alice: alice, bob: bob} do
      users = TestRepo.preload(blue, [:users]).users
      assert Enum.member?(users, alice)
      refute Enum.member?(users, bob)
    end

    # `from` expansion ignores `__schema__(:query)`
    # See: https://github.com/elixir-ecto/ecto/blob/master/lib/ecto/query/builder/from.ex#L75-L80
    test "uses unscoped in `from` macro", %{alice: alice, bob: bob, charlie: charlie} do
      users = TestRepo.all(from(q in User))
      assert Enum.member?(users, alice)
      assert Enum.member?(users, bob)
      assert Enum.member?(users, charlie)
    end

    # `join` expansion ignores `__schema__(:query)`
    # See: https://github.com/elixir-ecto/ecto/blob/master/lib/ecto/query/builder/join.ex#L91-L93
    test "uses unscoped in `join` macro", %{alice: alice, bob: bob, charlie: charlie} do
      users = TestRepo.all(from(q in User.scoped(), join: t in Team, on: t.id == q.team_id))

      assert Enum.member?(users, alice)
      refute Enum.member?(users, bob)
      assert Enum.member?(users, charlie)
    end

    test "provides `scoped/0` function", %{alice: alice, bob: bob, charlie: charlie} do
      # Demonstrates need to assert scoping with `from` and `join` macros
      users = TestRepo.all(from(q in User.scoped(), join: t in ^Team.scoped(), on: t.id == q.team_id))

      assert Enum.member?(users, alice)
      refute Enum.member?(users, bob)
      refute Enum.member?(users, charlie)
    end

    test "passing through `to_query` uses scoping", %{alice: alice, bob: bob, charlie: charlie} do
      # Simulate running through a query builder library like Inquisitor
      # This allows `__schema__(:query)` to be used before `from` expansion
      user_query = Ecto.Queryable.to_query(User)
      users = TestRepo.all(from(q in user_query))

      assert Enum.member?(users, alice)
      refute Enum.member?(users, bob)
      assert Enum.member?(users, charlie)
    end

    test "provides `unscoped/0` function", %{alice: alice, bob: bob, charlie: charlie} do
      users = TestRepo.all(User.unscoped())
      assert Enum.member?(users, alice)
      assert Enum.member?(users, bob)
      assert Enum.member?(users, charlie)
    end

    test "raises an exception with an invalid term" do
      assert_raise RuntimeError, ~r/#{__MODULE__}/, fn ->
        defmodule TestSchema do
          use Ecto.Rescope
          @rescope :foo
        end
      end
    end

    test "raises an exception with an anonymous function" do
      assert_raise RuntimeError, ~r/#{__MODULE__}/, fn ->
        defmodule TestSchema do
          use Ecto.Rescope
          @rescope fn x -> x end
        end
      end
    end
  end

  ## PRIVATE FUNCTIONS

  defp test_data(_conn) do
    blue = %Team{name: "Blue"} |> TestRepo.insert!()
    red = %Team{name: "Red", is_deleted: true} |> TestRepo.insert!()

    alice = %User{name: "Alice", team_id: blue.id} |> TestRepo.insert!()
    bob = %User{name: "Bob", team_id: blue.id, is_deleted: true} |> TestRepo.insert!()
    charlie = %User{name: "Charlie", team_id: red.id} |> TestRepo.insert!()

    [blue: blue, alice: alice, bob: bob, charlie: charlie]
  end
end
