import espresso
import espresso/router.{static}
import espresso/static.{Dir, File}
import gleam/pgo
import gleam/option.{Some}
import routers/notes as note_router
import schema/notes
import repo
import repo/schema.{Field, Schema}
import repo/query.{from, select}
import gleam/io

pub fn main() {
  let notes =
    Schema(
      table: "notes",
      model: notes.new(),
      fields: [
        Field("id", schema.Integer),
        Field("title", schema.String),
        Field("content", schema.String),
      ],
      decoder: notes.from_db(),
    )

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

  from(notes)
  |> select(["*"])
  |> repo.all(db, notes.from_db)
  |> io.debug()

  let router =
    router.new()
    |> router.router("/notes", note_router.routes(db))
    |> static("/", File("public/index.html"))
    |> static("/[...]", Dir("public"))

  espresso.start(router)
}
