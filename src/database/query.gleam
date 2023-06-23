import gleam/int
import gleam/list
import gleam/pgo
import gleam/string_builder.{StringBuilder}
import database/schema.{Schema}

pub type Where =
  List(#(String, List(pgo.Value)))

pub type Query(a) {
  Query(
    from: Schema(a),
    select: List(String),
    where: List(String),
    bindings: List(pgo.Value),
  )
}

pub fn from(schema: Schema(a)) -> Query(a) {
  Query(from: schema, where: [], select: [], bindings: [])
}

pub fn select(query: Query(a), fields: List(String)) -> Query(a) {
  Query(..query, select: list.append(fields, query.select))
}

pub fn where(query: Query(a), bindings: Where) -> Query(a) {
  let where =
    bindings
    |> list.map(fn(where) {
      let #(field, _value) = where
      field
    })
    |> list.append(query.where)
  let bindings =
    bindings
    |> list.flat_map(fn(where) {
      let #(_field, value) = where
      value
    })
    |> list.append(query.bindings)
  Query(..query, where: list.append(query.where, where), bindings: bindings)
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
  |> build_where(query.where)
  |> string_builder.to_string()
}

fn build_where(query: StringBuilder, where: List(String)) -> StringBuilder {
  case where {
    [] -> query
    where -> {
      let where_fields =
        where
        |> list.map(fn(field) { string_builder.from_string(field) })
        |> string_builder.join(" AND ")

      query
      |> string_builder.append(" WHERE ")
      |> string_builder.append_builder(where_fields)
    }
  }
}

pub fn insert(schema: Schema(a)) -> String {
  let fields =
    list.filter_map(
      schema.fields,
      fn(field) {
        case field.name == schema.primary_key {
          True -> Error(Nil)
          False -> Ok(string_builder.from_string(field.name))
        }
      },
    )

  let replacements =
    list.index_map(
      fields,
      fn(i, _field) { string_builder.from_string("$" <> int.to_string(i + 1)) },
    )

  string_builder.new()
  |> string_builder.append("INSERT INTO ")
  |> string_builder.append(schema.table)
  |> string_builder.append("(")
  |> string_builder.append_builder(string_builder.join(fields, ", "))
  |> string_builder.append(") VALUES (")
  |> string_builder.append_builder(string_builder.join(replacements, ", "))
  |> string_builder.append(") RETURNING *")
  |> string_builder.to_string()
}

pub fn update(query: Query(a), fields: List(#(String, pgo.Value))) -> String {
  let offset = list.length(query.bindings)
  let updates =
    list.index_map(
      fields,
      fn(i, field) {
        let #(field, _value) = field
        string_builder.from_string(
          field <> " = $" <> int.to_string(i + offset + 1),
        )
      },
    )

  string_builder.new()
  |> string_builder.append("UPDATE ")
  |> string_builder.append(query.from.table)
  |> string_builder.append(" SET ")
  |> string_builder.append_builder(string_builder.join(updates, ", "))
  |> build_where(query.where)
  |> string_builder.append(" RETURNING *")
  |> string_builder.to_string()
}

pub fn delete(query: Query(a)) -> String {
  string_builder.new()
  |> string_builder.append("DELETE FROM ")
  |> string_builder.append(query.from.table)
  |> build_where(query.where)
  |> string_builder.append(" RETURNING *")
  |> string_builder.to_string()
}
