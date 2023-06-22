import espresso/request.{Request}
import espresso/response.{json, send}
import espresso/router.{delete, get, post, put}
import gleam/int
import gleam/io
import gleam/json
import gleam/option.{None, Some}
import gleam/pgo.{Connection}
import gleam/result
import repo
import schema/notes.{schema}
import repo/query.{from, select, where}

pub fn routes(db: Connection) {
  router.new()
  |> get(
    "/",
    fn(_req: Request(BitString)) {
      let result =
        schema()
        |> from()
        |> select(["*"])
        |> repo.all(db)

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
            repo.insert(
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
            |> repo.update(
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
        |> repo.one(db)

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
        repo.single(
          db,
          "delete from notes where id = $1 returning *",
          [pgo.int(id)],
          notes.from_db(),
        )

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
}
