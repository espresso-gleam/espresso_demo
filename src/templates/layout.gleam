import espresso/html

pub type Params =
  html.Element

pub fn render(params: Params) {
  html.t("html")
  |> html.a("lang", "en")
  |> html.c([
    html.t("head")
    |> html.c([
      html.t("meta")
      |> html.a("charset", "UTF-8"),
    ])
    |> html.c([
      html.t("meta")
      |> html.a("name", "viewport")
      |> html.a("content", "width=device-width, initial-scale=1.0"),
    ])
    |> html.c([
      html.t("title")
      |> html.c([html.txt("Notes")]),
    ])
    |> html.c([
      html.t("link")
      |> html.a(
        "href",
        "https://cdn.jsdelivr.net/npm/tailwindcss@2.2.16/dist/tailwind.min.css",
      )
      |> html.a("rel", "stylesheet"),
    ])
    |> html.c([
      html.t("script")
      |> html.a("src", "https://unpkg.com/htmx.org@1.9.2"),
    ])
    |> html.c([
      html.t("script")
      |> html.a("src", "https://unpkg.com/htmx.org/dist/ext/json-enc.js"),
    ])
    |> html.c([
      html.t("link")
      |> html.a("href", "/style.css")
      |> html.a("rel", "stylesheet"),
    ]),
  ])
  |> html.c([
    html.t("body")
    |> html.a("class", "bg-gray-100")
    |> html.c([
      html.t("div")
      |> html.a("class", "container mx-auto px-4 py-8")
      |> html.dyn({ params }),
    ]),
  ])
}
