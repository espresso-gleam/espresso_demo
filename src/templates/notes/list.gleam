import espresso/html
import schema/notes.{Note}
import templates/notes/note
import gleam/list

pub type Params =
  List(Note)

pub fn render(params: Params) {
  html.t("div")
  |> html.a("id", "notes")
  |> html.a(
    "class",
    "grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4 mt-8",
  )
  |> html.dyn({ list.map(params, fn(n) { note.render(n) }) })
}
