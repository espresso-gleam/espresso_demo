import database
import database/query.{from, select, where}
import espresso/request.{Request}
import espresso/response.{json, send}
import espresso/router.{delete, get, post, put}
import gleam/int
import gleam/io
import gleam/json
import gleam/pgo.{Connection}
import gleam/result
import schema/notes.{schema}

pub fn routes(db: Connection) {
  router.new()
  |> get(
    "/",
    fn(_req: Request(BitString, assigns, session)) {
      let res = {
        use notes <- result.then(
          schema()
          |> from()
          |> select(["*"])
          |> database.all(db),
        )

        Ok(
          notes
          |> json.array(of: notes.encode)
          |> response.json(),
        )
      }

      result.unwrap(res, send(500, "Error fetching notes"))
    },
  )
  |> post(
    "/",
    {
      use req <- notes.create_decoder
      let res = case req.body {
        Ok(note) -> {
          use note <- result.then(database.insert(
            schema(),
            [pgo.text(note.title), pgo.text(note.content)],
            db,
          ))
          Ok(
            note
            |> notes.encode()
            |> response.json(),
          )
        }

        Error(err) -> {
          io.debug(err)
          Ok(send(400, "Bad Request"))
        }
      }

      result.unwrap(res, send(500, "Error inserting note"))
    },
  )
  |> put(
    "/:id",
    {
      use req <- notes.update_decoder
      let res = case req.body {
        Ok(note) -> {
          use id <- result.then(request.get_param(req, "id"))
          use id <- result.then(int.parse(id))
          use note <- result.then(
            schema()
            |> from()
            |> where([#("id = $1", [pgo.int(id)])])
            |> database.update(
              [
                #("title", pgo.text(note.title)),
                #("content", pgo.text(note.content)),
              ],
              db,
            ),
          )

          Ok(
            note
            |> notes.encode()
            |> response.json(),
          )
        }
        _ -> Ok(send(400, "Bad Request"))
      }

      result.unwrap(res, send(500, "Error updating note"))
    },
  )
  |> get(
    "/:id",
    fn(req: Request(BitString, assigns, session)) {
      let res = {
        use id <- result.then(request.get_param(req, "id"))
        use id <- result.then(int.parse(id))
        use note <- result.then(
          schema()
          |> from()
          |> select(["*"])
          |> where([#("id = $1", [pgo.int(id)])])
          |> database.one(db),
        )

        Ok(
          note
          |> notes.encode()
          |> response.json(),
        )
      }

      result.unwrap(res, send(404, "Not found"))
    },
  )
  |> delete(
    "/:id",
    fn(req: Request(BitString, assigns, session)) {
      let res = {
        use id <- result.then(request.get_param(req, "id"))
        use id <- result.then(int.parse(id))
        use _note <- result.then(
          schema()
          |> from()
          |> where([#("id = $1", [pgo.int(id)])])
          |> database.delete(db),
        )
        Ok(send(204, ""))
      }

      result.unwrap(res, send(500, "Error deleting note"))
    },
  )
}
