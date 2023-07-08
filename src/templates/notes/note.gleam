import espresso/html.{a, c, t, txt}
import schema/notes.{Note}

pub type Params =
  Note

pub fn render(params: Params) {
  t("div")
  |> a("class", "bg-white rounded-lg shadow p-4")
  |> c([
    t("h2")
    |> a("class", "text-lg font-semibold mb-2")
    |> c([txt(params.title)]),
    t("p")
    |> a("class", "text-gray-600")
    |> c([txt(params.content)]),
  ])
}
