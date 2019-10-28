# Ecto.Rescope

![travis ci badge](https://travis-ci.org/erikreedstrom/ecto_rescope.svg?branch=master)

Extends Ecto to allow rescoping of the default schema query.

A typical usecase for this functionality is excluding soft-deleted records by default.

## Usage

The most basic example for rescoping is to add directly to a schema with an inline function.

```elixir
defmodule User do
  use Ecto.Schema

  import Ecto.Query, only: [from: 2]
  import Ecto.Rescope

  schema "users" do
    field(:is_deleted, :boolean)
  end

  rescope(fn query -> 
    from(q in query, where: q.is_deleted == false)
  end)
end
```

In a more abstracted example, we might move the logic to a separate module for reuse.

```elixir
defmodule SoftDelete do
  import Ecto.Query, only: [from: 2]

  def exclude_deleted(query) do
    from(q in query, where: q.is_deleted == false)
  end
end

defmodule User do
  use Ecto.Schema
  
  import Ecto.Rescope

  schema "users" do
    field(:is_deleted, :boolean)
  end

  rescope(&SoftDelete.exclude_deleted/1)
end
```

It is possible to add a `@rescope` attribute to your schema with an external function.

```elixir
defmodule SoftDelete do
  import Ecto.Query, only: [from: 2]

  def exclude_deleted(query) do
    from(q in query, where: q.is_deleted == false)
  end
end

defmodule User do
  use Ecto.Schema
  use Ecto.Rescope

  @rescope &SoftDelete.exclude_deleted/1
  schema "users" do
    field(:is_deleted, :boolean)
  end

end
```

When we want to query without the default scoping applied, we can do so with `unscoped/0`, 
which is added by the `rescope/1` macro.

```elixir
User.unscoped()
```

## Caveats

### Using with `Ecto.Query` API

When using `from` or `join` macros from the `Ecto.Query` api, the query builder defines the 
queryable source at runtime, thus ignoring `__schema__(:query)` and the associated override.

Because of this, queries such as the following will not work as expected:

```elixir
from(q in User, join: t in Team, on: t.id == q.team_id)

# SELECT u0."id", u0."name", u0."is_deleted", u0."team_id" FROM "users" AS u0 INNER JOIN "teams" AS t1 ON 
# t1."id" = u0."team_id" []
```

Note the lack of `(u0."is_deleted" = FALSE)` or `(t1."is_deleted" = FALSE)` in the associated SQL log.

However, this can be worked around using the `scoped/0` function that is defined by the `rescope/0` macro.

```elixir
from(q in User.scoped(), join: t in ^Team.scoped(), on: t.id == q.team_id)

# SELECT u0."id", u0."name", u0."is_deleted", u0."team_id" FROM "users" AS u0 INNER JOIN "teams" AS t1 ON 
# (t1."is_deleted" = FALSE) AND (t1."id" = u0."team_id") WHERE (u0."is_deleted" = FALSE) []
```

> NOTE: Although this can seem a bit cumbersome, when using query building libraries such as DockYard's 
> [Inquisitor](https://github.com/DockYard/inquisitor), the problem is avoided as the queryable module is converted 
> to a query struct prior to being used within the `from` macro.

### Private API

This library overrides private reflection functions defined on schemas by the `ecto` library, specifically 
`__schema__(:query)` ([source](https://github.com/elixir-ecto/ecto/blob/master/lib/ecto/schema.ex#L548-L555)). 
While this technique has been used stable in production for multiple years, there is no guarantee `ecto` 
won't change the underlying functionality at some point in the future.

## Installation

The package can be installed by adding `ecto_rescope` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_rescope, "~> 0.1.0"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/ecto_rescope](https://hexdocs.pm/ecto_rescope).

## License

The source code is under the Apache 2 License.

Copyright (c) 2019 Erik Reedstrom

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance 
with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed 
on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License 
for the specific language governing permissions and limitations under the License.

