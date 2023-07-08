import database
import database/query.{from, select}
import espresso
import espresso/request.{Request}
import espresso/response.{render, send}
import espresso/router.{static}
import espresso/static.{Dir}
import gleam/pgo
import gleam/option.{Some}
import templates/layout
import templates/index
import templates/notes/note
import schema/notes.{NewNote}
import gleam/json
import routers/notes as note_router

pub fn main() {
  let db =
    pgo.connect(
      pgo.Config(
        ..pgo.default_config(),
        host: "localhost",
        user: "postgres",
        password: Some("postgres"),
        database: "notes_database_dev",
        pool_size: 2,
      ),
    )

  let router =
    router.new()
    |> router.get(
      "/",
      fn(_req: Request(BitString, assigns, session)) {
        let result =
          notes.schema()
          |> from()
          |> select(["*"])
          |> database.all(db)

        case result {
          Ok(notes) ->
            index.Params(notes)
            |> index.render()
            |> layout.render()
            |> render()
          Error(_) -> {
            send(500, "Error fetching notes")
          }
        }
      },
    )
    |> router.post(
      "/create",
      {
        use req: Request(Result(NewNote, json.DecodeError), assigns, session) <-
          notes.create_decoder
        case req.body {
          Ok(note) -> {
            let result =
              database.insert(
                notes.schema(),
                [pgo.text(note.title), pgo.text(note.content)],
                db,
              )

            case result {
              Ok(note) -> {
                note
                |> note.render()
                |> render()
              }
              _ -> send(500, "Internal Server Error")
            }
          }

          _ -> send(400, "Bad Request")
        }
      },
    )
    |> router.router("/notes", note_router.routes(db))
    |> static("/[...]", Dir("public"))

  espresso.start(router)
}
