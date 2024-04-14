import gleam/erlang/process
import gleeunit/should
import shakespeare/actors/key_value
import shakespeare/actors/periodic.{Ms}

pub fn periodic_actor_test() {
  let assert Ok(counter) = key_value.start()
  key_value.set(counter, "count", 0)
  key_value.set(counter, "count_min", 0)

  let increment = fn() {
    let assert Ok(count) = key_value.get(counter, "count")
    key_value.set(counter, "count", count + 1)
  }

  let increment_min = fn() {
    let assert Ok(count) = key_value.get(counter, "count_min")
    key_value.set(counter, "count_min", count + 1)
  }

  periodic.start(do: increment, every: Ms(500))
  |> should.be_ok

  loop_until(
    fn() {
      process.sleep(500)
      increment_min()
      key_value.get(counter, "count") == Ok(5)
    },
    start: 0,
    max: 15,
  )

  key_value.get(counter, "count_min")
  |> should.equal(Ok(6))

  key_value.get(counter, "count")
  |> should.equal(Ok(5))
}

fn loop_until(
  condition: fn() -> Bool,
  start attempt: Int,
  max max_attempts: Int,
) {
  case condition() {
    True -> Nil
    False ->
      case attempt >= max_attempts {
        True -> should.fail()
        False -> loop_until(condition, attempt + 1, max_attempts)
      }
  }
}
