import espresso/html.{a, c, t, txt}
import schema/notes.{Note}
import gleam/int

pub type Params =
  Note

pub fn render(params: Params) {
  t("div")
  |> a("class", "bg-white shadow p-4 border-2 border-black relative")
  |> c([
    t("button")
    |> a("hx-delete", "/delete/" <> int.to_string(params.id))
    |> a("hx-confirm", "Are you sure?")
    |> a("type", "button")
    |> a("hx-target", "#notes")
    |> a("hx-swap", "outerHTML")
    |> a(
      "class",
      "absolute top-2 right-2 w-6 h-6 flex text-center items-center justify-center bg-gray-300 text-black hover:bg-gray-400 focus:outline-none border-2 border-black",
    )
    |> c([txt("x")]),
    t("h2")
    |> a("class", "text-lg font-semibold mb-2")
    |> c([txt(params.title)]),
    t("p")
    |> a("class", "text-gray-600 whitespace-pre")
    |> c([txt(params.content)]),
  ])
}
