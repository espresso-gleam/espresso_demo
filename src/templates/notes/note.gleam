import espresso/html.{a, c, t, txt}
import schema/notes.{Note}

pub type Params =
  Note

pub fn render(params: Params) {
  t("div")
  |> a("class", "bg-white shadow p-4 border-2 border-black")
  |> c([
    t("h2")
    |> a("class", "text-lg font-semibold mb-2")
    |> c([txt(params.title)]),
    t("p")
    |> a("class", "text-gray-600 whitespace-pre")
    |> c([txt(params.content)]),
  ])
}
