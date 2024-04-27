//// An actor that runs on a schedule.

import birl.{type Time, type Weekday}
import birl/duration
import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/order
import gleam/otp/actor
import gleam/result
import shakespeare.{type Thunk}

/// A schedule for a `ScheduledActor`.
pub type Schedule {
  /// The actor runs hourly, at the specified minute and second.
  Hourly(minute: Int, second: Int)
  /// The actor runs daily, at the specified hour, minute, and second.
  Daily(hour: Int, minute: Int, second: Int)
  /// The actor runs weekly, at the specified day, hour, minute, and second.
  Weekly(day: Weekday, hour: Int, minute: Int, second: Int)
}

/// An actor that performs a given action on a schedule.
pub opaque type ScheduledActor {
  ScheduledActor(subject: Subject(Message))
}

/// Starts a new `ScheduledActor` that executes the given function on the
/// specified schedule.
pub fn start(
  do do_work: Thunk,
  runs schedule: Schedule,
) -> Result(ScheduledActor, actor.StartError) {
  actor.start_spec(actor.Spec(
    init: fn() { init(schedule, do_work) },
    loop: loop,
    init_timeout: 100,
  ))
  |> result.map(ScheduledActor)
}

type Message {
  Run
}

type State {
  State(self: Subject(Message), schedule: Schedule, do_work: Thunk)
}

fn init(occurrence: Schedule, do_work: Thunk) {
  let subject = process.new_subject()
  let state = State(subject, occurrence, do_work)

  let selector =
    process.new_selector()
    |> process.selecting(subject, fn(x) { x })

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
  let now = birl.utc_now()

  let ms_until_next_occurrence =
    next_occurrence_at(now, state.schedule)
    |> birl.difference(now)
    |> duration_to_milliseconds

  process.send_after(state.self, ms_until_next_occurrence, Run)
  Nil
}

/// Returns the time of the next occurrence for the given schedule.
pub fn next_occurrence_at(now: Time, schedule: Schedule) -> Time {
  case schedule {
    Hourly(minute, second) -> {
      let occurrence_this_hour =
        now
        |> birl.set_time_of_day(birl.TimeOfDay(
          birl.get_time_of_day(now).hour,
          minute,
          second,
          0,
        ))

      case birl.compare(now, occurrence_this_hour) {
        order.Lt | order.Eq -> occurrence_this_hour
        order.Gt -> {
          let in_one_hour =
            now
            |> birl.add(duration.hours(1))
          let hour = birl.get_time_of_day(in_one_hour).hour

          in_one_hour
          |> birl.set_time_of_day(birl.TimeOfDay(hour, minute, second, 0))
        }
      }
    }
    Daily(hour, minute, second) -> {
      let occurrence_this_day =
        now
        |> birl.set_time_of_day(birl.TimeOfDay(hour, minute, second, 0))

      case birl.compare(now, occurrence_this_day) {
        order.Lt | order.Eq -> occurrence_this_day
        order.Gt -> {
          now
          |> birl.add(duration.days(1))
          |> birl.set_time_of_day(birl.TimeOfDay(hour, minute, second, 0))
        }
      }
    }
    Weekly(day, hour, minute, second) -> {
      let current_day = birl.weekday(now)
      let day_diff = weekday_to_int(day) - weekday_to_int(current_day)

      case int.compare(day_diff, 0) {
        order.Gt | order.Eq -> {
          now
          |> birl.add(duration.days(day_diff))
          |> birl.set_time_of_day(birl.TimeOfDay(hour, minute, second, 0))
        }
        order.Lt -> {
          now
          |> birl.add(duration.days(7 + day_diff))
          |> birl.set_time_of_day(birl.TimeOfDay(hour, minute, second, 0))
        }
      }
    }
  }
}

fn duration_to_milliseconds(duration: duration.Duration) -> Int {
  let duration.Duration(microseconds) = duration
  microseconds / 1000
}

fn weekday_to_int(value: Weekday) -> Int {
  case value {
    birl.Sun -> 0
    birl.Mon -> 1
    birl.Tue -> 2
    birl.Wed -> 3
    birl.Thu -> 4
    birl.Fri -> 5
    birl.Sat -> 6
  }
}
