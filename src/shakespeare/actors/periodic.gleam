//// An actor that runs periodically.

import gleam/erlang/process.{type Subject}
import gleam/function.{identity}
import gleam/otp/actor
import gleam/result
import shakespeare.{type Thunk}

/// An interval of time.
pub type Interval {
  /// An interval in milliseconds.
  Ms(Int)
}

/// An actor that performs a given action periodically.
pub opaque type PeriodicActor {
  PeriodicActor(subject: Subject(Message))
}

/// Starts a new `PeriodicActor` that executes the given function on the
/// specified interval.
pub fn start(
  do do_work: Thunk,
  every interval: Interval,
) -> Result(PeriodicActor, actor.StartError) {
  actor.start_spec(actor.Spec(
    init: fn() { init(interval, do_work) },
    loop: loop,
    init_timeout: 100,
  ))
  |> result.map(PeriodicActor)
}

type Message {
  Run
}

type State {
  State(self: Subject(Message), interval: Interval, do_work: Thunk)
}

fn init(interval: Interval, do_work: Thunk) {
  let subject = process.new_subject()
  let state = State(subject, interval, do_work)

  let selector =
    process.new_selector()
    |> process.selecting(subject, identity)

  process.send(subject, Run)

  enqueue_next_run(state)
  actor.Ready(state, selector)
}

fn loop(message: Message, state: State) -> actor.Next(Message, State) {
  case message {
    Run -> {
      state.do_work()

      enqueue_next_run(state)
      actor.continue(state)
    }
  }
}

fn enqueue_next_run(state: State) -> Nil {
  let Ms(interval) = state.interval

  process.send_after(state.self, interval, Run)
  Nil
}
