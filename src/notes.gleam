import espresso
import espresso/router.{static}
import espresso/static.{Dir, File}
import gleam/pgo
import gleam/option.{Some}
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
    |> router.router("/notes", note_router.routes(db))
    |> static("/", File("public/index.html"))
    |> static("/[...]", Dir("public"))

  espresso.start(router)
}
