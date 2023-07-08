import espresso/html.{a, c, t, txt}
import gleam/list
import schema/notes.{Note}

pub type Params {
  Params(notes: List(Note))
}

pub fn render(params: Params) {
  t("main")
  |> c([
    t("h1")
    |> a("class", "text-2xl font-bold mb-4")
    |> c([txt("Notes")]),
    t("div")
    |> a("class", "mt-4")
    |> c([
      t("h2")
      |> a("class", "text-lg font-semibold mb-2")
      |> c([txt("Create a New Note")]),
      t("form")
      |> a("hx-post", "/create")
      |> a("hx-ext", "json-enc")
      |> a("hx-target", "#notes")
      |> a("hx-swap", "beforeend")
      |> a("hx-on", "htmx:afterRequest: this.reset()")
      |> c([
        t("div")
        |> a("class", "mb-4")
        |> c([
          t("label")
          |> a("class", "block text-gray-700 text-sm font-bold mb-2")
          |> a("for", "title")
          |> c([txt("Title:")]),
          t("input")
          |> a(
            "class",
            "shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline",
          )
          |> a("id", "title")
          |> a("name", "title")
          |> a("type", "text")
          |> a("placeholder", "Enter title")
          |> a("required", "")
          |> c([]),
        ]),
        t("div")
        |> a("class", "mb-4")
        |> c([
          t("label")
          |> a("class", "block text-gray-700 text-sm font-bold mb-2")
          |> a("for", "content")
          |> c([txt("Content:")]),
          t("textarea")
          |> a(
            "class",
            "shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline",
          )
          |> a("id", "content")
          |> a("name", "content")
          |> a("placeholder", "Enter content")
          |> a("required", "")
          |> c([]),
        ]),
        t("button")
        |> a(
          "class",
          "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline",
        )
        |> a("type", "submit")
        |> c([txt("Create Note")]),
      ]),
    ]),
    t("div")
    |> a("id", "notes")
    |> a("class", "mt-8 grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4")
    |> c([
      t("span")
      |> a("style", "display: none")
      |> c([]),
      ..list.map(
        params.notes,
        fn(note) {
          t("div")
          |> a("class", "bg-white rounded-lg shadow p-4")
          |> c([
            t("h2")
            |> a("class", "text-lg font-semibold mb-2")
            |> c([txt(note.title)]),
            t("p")
            |> a("class", "text-gray-600")
            |> c([txt(note.content)]),
          ])
        },
      )
    ]),
  ])
}
