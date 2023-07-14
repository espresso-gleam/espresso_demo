import espresso/html
import schema/notes.{Note}
import gleam/int

pub type Params =
  Note

pub fn render(params: Params) {
  html.t("div")
  |> html.a("class", "bg-white shadow p-4 border-2 border-black relative")
  |> html.c([
    html.t("button")
    |> html.a("hx-delete", "/delete/" <> int.to_string(params.id))
    |> html.a("hx-confirm", "Are you sure?")
    |> html.a("type", "button")
    |> html.a("hx-target", "#notes")
    |> html.a("hx-swap", "outerHTML")
    |> html.a(
      "class",
      "absolute top-2 right-2 w-6 h-6 flex text-center items-center justify-center bg-gray-300 text-black hover:bg-gray-400 focus:outline-none border-2 border-black",
    )
    |> html.c([
      html.txt(
        "x
    ",
      ),
    ]),
  ])
  |> html.c([
    html.t("h2")
    |> html.a("class", "text-lg font-semibold mb-2")
    |> html.dyn({ params.title }),
  ])
  |> html.c([
    html.t("p")
    |> html.a("class", "text-gray-600 whitespace-pre")
    |> html.dyn({ params.content }),
  ])
}
