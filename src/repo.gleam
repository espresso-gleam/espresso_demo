import gleam/pgo.{Connection, QueryError, Value}
import gleam/dynamic
import gleam/list
import gleam/option.{None, Option}
import gleam/io
import repo/query.{Query}
import repo/schema.{Schema}

pub fn all(q: Query(a), db: Connection) -> Result(List(a), QueryError) {
  let sql = query.build(q)
  case pgo.execute(sql, db, q.bindings, q.from.decoder) {
    Ok(result) -> Ok(result.rows)

    Error(e) -> {
      Error(e)
    }
  }
}

pub fn one(q: Query(a), db: Connection) -> Option(a) {
  let sql = query.build(q)
  case pgo.execute(sql, db, q.bindings, q.from.decoder) {
    Ok(result) -> {
      result.rows
      |> list.first()
      |> option.from_result()
    }

    Error(_e) -> {
      None
    }
  }
}

pub fn insert(
  schema: Schema(a),
  data: List(pgo.Value),
  db: Connection,
) -> Result(a, QueryError) {
  let sql = query.insert(schema)

  case pgo.execute(sql, db, data, schema.decoder) {
    Ok(result) -> {
      case list.first(result.rows) {
        Ok(result) -> Ok(result)
        Error(_e) -> Error(pgo.UnexpectedResultType([]))
      }
    }

    Error(e) -> {
      io.debug(e)
      Error(e)
    }
  }
}

pub fn update(
  query: Query(a),
  data: List(#(String, pgo.Value)),
  db: Connection,
) -> Result(a, QueryError) {
  let sql = query.update(query, data)

  let bindings =
    list.append(
      query.bindings,
      list.map(
        data,
        fn(field) {
          let #(_field, value) = field
          value
        },
      ),
    )

  case pgo.execute(sql, db, bindings, query.from.decoder) {
    Ok(result) -> {
      case list.first(result.rows) {
        Ok(result) -> Ok(result)
        Error(_e) -> Error(pgo.UnexpectedResultType([]))
      }
    }

    Error(e) -> {
      io.debug(e)
      Error(e)
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
