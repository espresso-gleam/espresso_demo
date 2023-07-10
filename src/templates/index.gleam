import espresso/html.{a, c, t, txt}
import templates/notes/list as note
import schema/notes.{Note}

pub type Params {
  Params(notes: List(Note))
}

pub fn render(params: Params) {
  t("main")
  |> a("class", "border-2 border-solid border-black")
  |> c([
    t("div")
    |> a("class", "p-2 flex items-center bg-indigo-600 text-white")
    |> c([
      t("div")
      |> a("class", "w-4 h-4 rounded-full bg-red-600 mr-2")
      |> c([]),
      t("div")
      |> a("class", "w-4 h-4 rounded-full bg-yellow-500 mr-2")
      |> c([]),
      t("div")
      |> a("class", "w-4 h-4 rounded-full bg-green-500 mr-2")
      |> c([]),
      t("span")
      |> a("class", "font-bold")
      |> c([txt("Notes")]),
    ]),
    t("div")
    |> a("class", "container mx-auto px-4 py-4")
    |> c([
      t("div")
      |> c([
        t("h2")
        |> a("class", "text-lg font-semibold mb-2 text-black")
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
            |> a("class", "block text-black text-sm font-bold mb-2")
            |> a("for", "title")
            |> c([txt("Title:")]),
            t("input")
            |> a(
              "class",
              "shadow appearance-none border-2 border-black w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline bg-white",
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
            |> a("class", "block text-black text-sm font-bold mb-2")
            |> a("for", "content")
            |> c([txt("Content:")]),
            t("textarea")
            |> a(
              "class",
              "shadow appearance-none border-2 border-black w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline bg-white",
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
            "bg-gray-300 hover:bg-gray-400 text-black font-bold py-2 px-4 transition duration-300 ease-in-out transform focus:outline-none focus:shadow-outline active:scale-95 active:translate-y-1 active:shadow-none active:bg-gray-500 active:text-white border-2 border-black",
          )
          |> a("type", "submit")
          |> c([txt("Create Note")]),
        ]),
      ]),
      note.render(params.notes),
    ]),
  ])
}
