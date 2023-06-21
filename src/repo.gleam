import gleam/pgo.{Connection, Value}
import gleam/dynamic
import gleam/list
import gleam/option.{None, Option}
import gleam/io

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
