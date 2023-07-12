import espresso/html
import templates/notes/list as note
import schema/notes.{Note}
import gleam/io

pub type Params {
  Params(notes: List(Note))
}

pub fn render(params: Params) {
  html.t("main")
  |> html.a("class", "border-2 border-solid border-black")
  |> html.c([
    html.t("div")
    |> html.a("class", "p-2 flex items-center bg-indigo-600 text-white")
    |> html.c([
      html.t("div")
      |> html.a("class", "w-4 h-4 rounded-full bg-red-600 mr-2"),
    ])
    |> html.c([
      html.t("div")
      |> html.a("class", "w-4 h-4 rounded-full bg-yellow-500 mr-2"),
    ])
    |> html.c([
      html.t("div")
      |> html.a("class", "w-4 h-4 rounded-full bg-green-500 mr-2"),
    ])
    |> html.c([
      html.t("span")
      |> html.a("class", "font-bold")
      |> html.c([html.txt("Notes")]),
    ]),
  ])
  |> html.c([
    html.t("div")
    |> html.a("class", "container mx-auto px-4 py-4")
    |> html.c([
      html.t("div")
      |> html.c([
        html.t("h2")
        |> html.a("class", "text-lg font-semibold mb-2 text-black")
        |> html.c([html.txt("Create a New Note")]),
      ])
      |> html.c([
        html.t("form")
        |> html.a("hx-post", "/create")
        |> html.a("hx-ext", "json-enc")
        |> html.a("hx-target", "#notes")
        |> html.a("hx-swap", "beforeend")
        |> html.a("hx-on", "htmx:afterRequest: this.reset()")
        |> html.c([
          html.t("div")
          |> html.a("class", "mb-4")
          |> html.c([
            html.t("label")
            |> html.a("class", "block text-black text-sm font-bold mb-2")
            |> html.a("for", "title")
            |> html.c([html.txt("Title:")]),
          ])
          |> html.c([
            html.t("input")
            |> html.a(
              "class",
              "shadow appearance-none border-2 border-black w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline bg-white",
            )
            |> html.a("id", "title")
            |> html.a("name", "title")
            |> html.a("type", "text")
            |> html.a("placeholder", "Enter title")
            |> html.a("required", "true"),
          ]),
        ])
        |> html.c([
          html.t("div")
          |> html.a("class", "mb-4")
          |> html.c([
            html.t("label")
            |> html.a("class", "block text-black text-sm font-bold mb-2")
            |> html.a("for", "content")
            |> html.c([html.txt("Content:")]),
          ])
          |> html.c([
            html.t("textarea")
            |> html.a(
              "class",
              "shadow appearance-none border-2 border-black w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline bg-white",
            )
            |> html.a("id", "content")
            |> html.a("name", "content")
            |> html.a("placeholder", "Enter content")
            |> html.a("required", "true"),
          ]),
        ])
        |> html.c([
          html.t("button")
          |> html.a(
            "class",
            "bg-gray-300 hover:bg-gray-400 text-black font-bold py-2 px-4 transition duration-300 ease-in-out transform focus:outline-none focus:shadow-outline active:scale-95 active:translate-y-1 active:shadow-none active:bg-gray-500 active:text-white border-2 border-black",
          )
          |> html.a("type", "submit")
          |> html.c([
            html.txt(
              "Create Note
          ",
            ),
          ]),
        ]),
      ]),
    ])
    |> html.dyn({ note.render(params.notes) }),
  ])
}
