import gleam/pgo.{Connection, Value}
import gleam/dynamic
import gleam/list
import gleam/option.{None, Option}
import gleam/io
import repo/query.{Query}

pub fn all(
  q: Query(a),
  db: Connection,
  decoder: fn() -> fn(dynamic.Dynamic) -> Result(a, List(dynamic.DecodeError)),
) -> List(a) {
  let sql = query.build(q)
  let values = []
  case pgo.execute(sql, db, values, decoder()) {
    Ok(result) -> result.rows

    error -> {
      io.debug(error)
      []
    }
  }
}

pub fn single(
  db: Connection,
  sql: String,
  values: List(Value),
  decoder: fn(dynamic.Dynamic) -> Result(a, List(dynamic.DecodeError)),
) -> Option(a) {
  case pgo.execute(sql, db, values, decoder) {
    Ok(result) ->
      result.rows
      |> list.first()
      |> option.from_result()

    error -> {
      io.debug(error)
      None
    }
  }
}
