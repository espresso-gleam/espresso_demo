import gleam/pgo.{Value}
import gleam/dynamic

pub type Schema(a) {
  Schema(
    table: String,
    primary_key: String,
    fields: List(Field),
    decoder: dynamic.Decoder(a),
  )
}

pub type Field {
  Field(name: String, type_: FieldType)
}

pub type FieldType {
  Integer
  String
}

pub fn integer(i: Int) -> Value {
  pgo.int(i)
}

pub fn string(str: String) {
  pgo.text(str)
}
