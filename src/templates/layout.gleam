import espresso/html.{a, c, t, txt}

pub type Params =
  html.Element

pub fn render(params: Params) {
  t("html")
  |> a("lang", "en")
  |> c([
    t("head")
    |> c([
      t("meta")
      |> a("charset", "UTF-8")
      |> c([]),
      t("meta")
      |> a("name", "viewport")
      |> a("content", "width=device-width, initial-scale=1.0")
      |> c([]),
      t("title")
      |> c([txt("Notes")]),
      t("link")
      |> a(
        "href",
        "https://cdn.jsdelivr.net/npm/tailwindcss@2.2.16/dist/tailwind.min.css",
      )
      |> a("rel", "stylesheet")
      |> c([]),
      t("script")
      |> a("src", "https://unpkg.com/htmx.org@1.9.2")
      |> c([]),
      t("script")
      |> a("src", "https://unpkg.com/htmx.org/dist/ext/json-enc.js")
      |> c([]),
    ]),
    t("body")
    |> a("class", "bg-gray-100")
    |> c([
      t("div")
      |> a("class", "container mx-auto px-4 py-8")
      |> c([params]),
    ]),
  ])
}
