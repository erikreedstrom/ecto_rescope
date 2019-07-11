defmodule SoftDelete do
  import Ecto.Query, only: [from: 2]

  def exclude_deleted(query) do
    from(q in query, where: q.is_deleted == false)
  end
end
