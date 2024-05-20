//// An actor that broadcasts messages to multiple subjects.

import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import gleam/result
import gleam/set.{type Set}

/// An actor that broadcasts messages to multiple subjects.
pub opaque type BroadcastActor(a) {
  BroadcastActor(subject: Subject(Message(a)))
}

/// Starts a new `BroadcastActor`.
pub fn start() -> Result(BroadcastActor(a), actor.StartError) {
  actor.start(set.new(), handle_message)
  |> result.map(BroadcastActor)
}

/// Adds a subject to list of subjects to broadcast to.
///
/// If this subject is already present, it will not be added again.
pub fn register(actor: BroadcastActor(a), subject: Subject(a)) {
  process.send(actor.subject, Register(subject))
}

/// Removes a subject from the list of subjects to broadcast to.
///
/// If this subject isn't present, nothing happens.
pub fn unregister(actor: BroadcastActor(a), subject: Subject(a)) {
  process.send(actor.subject, Unregister(subject))
}

/// Broadcasts a message to all registered subjects.
///
/// The order in which messages are delivered to
/// each of the registered subjects is unspecified.
pub fn send(actor: BroadcastActor(a), message: a) {
  process.send(actor.subject, Send(message))
}

type Message(a) {
  Register(subject: Subject(a))
  Unregister(subject: Subject(a))
  Send(msg: a)
}

fn handle_message(
  message: Message(a),
  state: Set(Subject(a)),
) -> actor.Next(Message(a), Set(Subject(a))) {
  case message {
    Register(subject) ->
      actor.continue(
        state
        |> set.insert(subject),
      )

    Unregister(subject) ->
      actor.continue(
        state
        |> set.delete(subject),
      )

    Send(inner) -> {
      state
      |> set.fold(Nil, fn(_, dest) { process.send(dest, inner) })
      actor.continue(state)
    }
  }
}
