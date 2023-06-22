import gleam/dynamic
import gleam/json
import espresso/request.{Request}
import espresso/response.{Response}
import espresso/service.{Service}
import gleam/bit_string
import gleam/result
import repo/schema.{Field, Schema}

pub type Note {
  Note(id: Int, title: String, content: String)
}

pub fn new() {
  Note(id: 0, title: "", content: "")
}

pub fn schema() {
  Schema(
    table: "notes",
    primary_key: "id",
    fields: [
      Field("id", schema.Integer),
      Field("title", schema.String),
      Field("content", schema.String),
    ],
    // Would be nice if we could generate this from fields
    decoder: dynamic.decode3(
      Note,
      dynamic.element(0, dynamic.int),
      dynamic.element(1, dynamic.string),
      dynamic.element(2, dynamic.string),
    ),
  )
}

pub fn encode(note: Note) {
  json.object([
    #("id", json.int(note.id)),
    #("title", json.string(note.title)),
    #("content", json.string(note.content)),
  ])
}

pub type CreateNote {
  CreateNote(title: String, content: String)
}

pub fn decode_create(body: String) -> Result(CreateNote, json.DecodeError) {
  let decoder =
    dynamic.decode2(
      CreateNote,
      dynamic.field("title", of: dynamic.string),
      dynamic.field("content", of: dynamic.string),
    )

  json.decode(from: body, using: decoder)
}

pub fn decode(body: String) {
  let decoder =
    dynamic.decode3(
      Note,
      dynamic.field("id", of: dynamic.int),
      dynamic.field("title", of: dynamic.string),
      dynamic.field("content", of: dynamic.string),
    )

  json.decode(from: body, using: decoder)
}

pub fn create_decoder(
  handler: Service(Result(CreateNote, json.DecodeError), a),
) -> Service(BitString, a) {
  fn(req: Request(BitString)) -> Response(a) {
    request.map(
      req,
      fn(body) {
        body
        |> bit_string.to_string()
        |> result.unwrap("")
        |> decode_create()
      },
    )
    |> handler()
  }
}

pub fn update_decoder(
  handler: Service(Result(Note, json.DecodeError), a),
) -> Service(BitString, a) {
  fn(req: Request(BitString)) -> Response(a) {
    request.map(
      req,
      fn(body) {
        body
        |> bit_string.to_string()
        |> result.unwrap("")
        |> decode()
      },
    )
    |> handler()
  }
}

pub fn from_db() -> fn(dynamic.Dynamic) ->
  Result(Note, List(dynamic.DecodeError)) {
  dynamic.decode3(
    Note,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
  )
}
