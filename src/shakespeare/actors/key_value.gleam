//// An actor that provides a simple key-value store.

import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import gleam/result

/// An actor that serves as an in-memory key-value store.
pub opaque type KeyValueActor(a) {
  KeyValueActor(subject: Subject(Message(a)))
}

/// Starts a new `KeyValueActor`.
pub fn start() -> Result(KeyValueActor(a), actor.StartError) {
  actor.start(dict.new(), handle_message)
  |> result.map(KeyValueActor)
}

/// Sets the value associated with the given key.
///
/// If value already exists for the given key it will be overwritten.
pub fn set(actor: KeyValueActor(a), key: String, value: a) {
  process.send(actor.subject, Set(key, value))
}

/// Gets the value for the given key.
pub fn get(actor: KeyValueActor(a), key: String) -> Result(a, Nil) {
  process.try_call(actor.subject, Get(key, _), 10)
  |> result.map_error(fn(_) { Nil })
  |> result.flatten
}

type Message(a) {
  Set(key: String, value: a)
  Get(name: String, reply_with: Subject(Result(a, Nil)))
}

fn handle_message(
  message: Message(a),
  state: Dict(String, a),
) -> actor.Next(Message(a), Dict(String, a)) {
  case message {
    Set(key, value) -> {
      actor.continue(
        state
        |> dict.insert(key, value),
      )
    }
    Get(key, client) -> {
      let value =
        state
        |> dict.get(key)

      process.send(client, value)
      actor.continue(state)
    }
  }
}
