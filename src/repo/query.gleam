import gleam/list
import gleam/string_builder
import repo/schema.{Field, Schema}

pub type Query(a) {
  Query(from: Schema(a), select: List(String), where: List(Field))
}

pub fn from(schema: Schema(a)) -> Query(a) {
  Query(from: schema, where: [], select: [])
}

pub fn select(query: Query(a), fields: List(String)) -> Query(a) {
  Query(
    from: query.from,
    where: query.where,
    select: list.append(fields, query.select),
  )
}

pub fn build(query: Query(a)) -> String {
  let select_fields =
    query.select
    |> list.map(fn(field) { string_builder.from_string(field) })
    |> string_builder.join(", ")

  string_builder.new()
  |> string_builder.append("SELECT ")
  |> string_builder.append_builder(select_fields)
  |> string_builder.append(" FROM ")
  |> string_builder.append(query.from.table)
  |> string_builder.to_string()
}
