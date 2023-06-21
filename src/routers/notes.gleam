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
import schema/notes

pub fn routes(db: Connection) {
  router.new()
  |> get(
    "/",
    fn(_req: Request(BitString)) {
      let result =
        pgo.execute(
          "select id, title, content from notes",
          db,
          [],
          notes.from_db(),
        )

      case result {
        Ok(result) -> {
          result.rows
          |> json.array(of: notes.encode)
          |> response.json()
        }

        Error(error) -> {
          io.debug(error)
          send(500, "Error loading notes")
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
            repo.single(
              db,
              "insert into notes (title, content) values ($1, $2) returning *",
              [pgo.text(note.title), pgo.text(note.content)],
              notes.from_db(),
            )
          case result {
            Some(note) ->
              note
              |> notes.encode()
              |> response.json()

            None -> {
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
            repo.single(
              db,
              "update notes set title = $1, content = $2 where id = $3 returning *",
              [pgo.text(note.title), pgo.text(note.content), pgo.int(id)],
              notes.from_db(),
            )
          case result {
            Some(note) ->
              note
              |> notes.encode()
              |> response.json()

            None -> {
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
        repo.single(
          db,
          "select id, title, content from notes where id = $1",
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
