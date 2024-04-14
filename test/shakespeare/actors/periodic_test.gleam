import gleam/erlang/process
import gleeunit/should
import shakespeare/actors/key_value
import shakespeare/actors/periodic.{Ms}

pub fn periodic_actor_test() {
  let count_key = "count"
  let assert Ok(counter) = key_value.start()
  key_value.set(counter, count_key, 0)

  let increment = fn() {
    let assert Ok(count) = key_value.get(counter, count_key)
    key_value.set(counter, count_key, count + 1)
  }

  periodic.start(do: increment, every: Ms(10))
  |> should.be_ok

  process.sleep(50)

  key_value.get(counter, count_key)
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
