import database
import database/query.{from, select, where}
import espresso/request.{Request}
import espresso/response.{json, send}
import espresso/router.{delete, get, post, put}
import gleam/int
import gleam/io
import gleam/json
import gleam/option.{None, Some}
import gleam/pgo.{Connection}
import gleam/result
import schema/notes.{schema}

pub fn routes(db: Connection) {
  router.new()
  |> get(
    "/",
    fn(_req: Request(BitString)) {
      let result =
        schema()
        |> from()
        |> select(["*"])
        |> database.all(db)

      case result {
        Ok(notes) ->
          notes
          |> json.array(of: notes.encode)
          |> response.json()
        Error(e) -> {
          io.debug(e)
          send(500, "Error fetching notes")
        }
      }
    },
  )
  |> post(
    "/",
    {
      use req <- notes.create_decoder
      case req.body {
        Ok(note) -> {
          let result =
            database.insert(
              schema(),
              [pgo.text(note.title), pgo.text(note.content)],
              db,
            )

          case result {
            Ok(note) ->
              note
              |> notes.encode()
              |> response.json()

            Error(_) -> {
              send(500, "Error inserting note")
            }
          }
        }

        Error(err) -> {
          io.debug(err)
          send(400, "Bad Request")
        }
      }
    },
  )
  |> put(
    "/:id",
    {
      use req <- notes.update_decoder
      case req.body {
        Ok(note) -> {
          let id =
            req
            |> request.get_param("id")
            |> option.unwrap("")
            |> int.parse()
            |> result.unwrap(-1)

          let result =
            schema()
            |> from()
            |> where([#("id = $1", [pgo.int(id)])])
            |> database.update(
              [
                #("title", pgo.text(note.title)),
                #("content", pgo.text(note.content)),
              ],
              db,
            )

          case result {
            Ok(note) ->
              note
              |> notes.encode()
              |> response.json()

            Error(e) -> {
              io.debug(e)
              send(500, "Error updating note")
            }
          }
        }

        Error(err) -> {
          io.debug(err)
          send(400, "Bad Request")
        }
      }
    },
  )
  |> get(
    "/:id",
    fn(req: Request(BitString)) {
      let id =
        req
        |> request.get_param("id")
        |> option.unwrap("")
        |> int.parse()
        |> result.unwrap(-1)

      let result =
        schema()
        |> from()
        |> select(["*"])
        |> where([#("id = $1", [pgo.int(id)])])
        |> database.one(db)

      case result {
        Some(note) -> {
          note
          |> notes.encode()
          |> response.json()
        }

        None -> {
          send(404, "Not found")
        }
      }
    },
  )
  |> delete(
    "/:id",
    fn(req: Request(BitString)) {
      let id =
        req
        |> request.get_param("id")
        |> option.unwrap("")
        |> int.parse()
        |> result.unwrap(-1)

      let result =
        schema()
        |> from()
        |> where([#("id = $1", [pgo.int(id)])])
        |> database.delete(db)

      case result {
        Ok(note) -> {
          note
          |> notes.encode()
          |> response.json()
        }

        Error(e) -> {
          io.debug(e)
          send(500, "Error deleting note")
        }
      }
    },
  )
}
