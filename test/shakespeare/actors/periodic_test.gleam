import gleam/erlang/process
import shakespeare/actors/key_value
import shakespeare/actors/periodic.{Ms}
import startest/expect

pub fn periodic_actor_test() {
  let count_key = "count"
  let assert Ok(counter) = key_value.start()
  key_value.set(counter, count_key, 0)

  let increment = fn() {
    let assert Ok(count) = key_value.get(counter, count_key)
    key_value.set(counter, count_key, count + 1)
  }

  periodic.start(do: increment, every: Ms(10))
  |> expect.to_be_ok

  process.sleep(50)

  key_value.get(counter, count_key)
  |> expect.to_equal(Ok(5))
}
