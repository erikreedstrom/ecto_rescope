defmodule Ecto.Rescope do
  @moduledoc """
  Rescopes the default query on an Ecto schema.

  An Ecto Schmea is typically scoped by the `Ecto.Schema.schema/2` macro,
  which defines the query as:

      def __schema__(:query) do
        %Ecto.Query{
          from: %Ecto.Query.FromExpr{
            source: {unquote(source), __MODULE__},
            prefix: unquote(prefix)
          }
        }
      end

  This has a downside in that the schema cannot define a default scope for
  all queries to follow. For instance, perhaps one wants to ensure that soft-deleted
  records are not returned by default. To accomplish this, one might exclude
  any record with an `is_deleted` field set to `true`.

      def without_deleted(query) do
        from(q in query, where: q.is_deleted == false)
      end

  ## Usage

  By using the `rescope/1` macro provided by `Ecto.Rescope`, one can override by
  passing a function that takes an `Ecto.Query` struct as the sole
  argument. This function must return an `Ecto.Query` struct.

  > NOTE: The macro must be invoked after the `Ecto.Schema.schema/2` macro.

  ### Example

      import Ecto.Rescope

      schema "user" do
        field(:is_deleted, :boolean)
      end

      rescope(&without_deleted/1)

      def without_deleted(query) do
        from(q in query, where: q.is_deleted == false)
      end

  At this point, any queries using the schema will now be defined with the new default scope.
  """

  @doc """
  Resets the default query on the Ecto schema.

  Accepts a 1-arity function that takes and returns an `Ecto.Query` struct.

  In addition to redefining the default scope, the macro defines two utility functions:
  `unscoped/0` and `scoped/0`. These are used in situations where the overridden scope is
  either undesirable, or caveats exist that prevent use of the rescoped query.

  See: [README](readme.html#caveats) for caveats
  """
  defmacro rescope(scope_fn) do
    quote do
      # Allow override of the schema function.
      defoverridable __schema__: 1

      @doc """
      Returns the default Ecto defined query for `#{__MODULE__}`.
      """
      @spec unscoped() :: Ecto.Query.t()
      def unscoped(), do: Ecto.Queryable.to_query({__schema__(:source), __MODULE__})

      # Invoke the defined query object from the module and pass
      # to the defalt scoping function for composition.
      def __schema__(:query), do: unquote(scope_fn).(super(:query))

      # Ensure we still allow fields, assocs, and embeds to process
      def __schema__(args), do: super(args)

      @doc """
      Returns the redefined scope query for `#{__MODULE__}`.
      """
      @spec scoped() :: Ecto.Query.t()
      def scoped(), do: __schema__(:query)
    end
  end
end
