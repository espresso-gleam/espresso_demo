import espresso/html.{a, c, t, txt}
import schema/notes.{Note}
import templates/notes/note
import gleam/list

pub type Params =
  List(Note)

pub fn render(params: Params) {
  t("div")
  |> a("id", "notes")
  |> a("class", "grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4 mt-8")
  |> c(list.map(params, fn(n) { note.render(n) }))
}
