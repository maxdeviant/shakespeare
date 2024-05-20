import gleam/erlang/process
import shakespeare/actors/broadcast
import startest/expect

type Foo {
  Foo(seq: Int)
}

pub fn broadcast_actor_test() {
  let subj1 = process.new_subject()
  let subj2 = process.new_subject()

  let assert Ok(broadcaster) = broadcast.start()

  // Expect message to be received by single registered subject
  broadcast.register(broadcaster, subj1)
  broadcast.send(broadcaster, Foo(1))
  process.receive(subj1, 100)
  |> expect.to_equal(Ok(Foo(1)))

  // Expect message to be received by both registered subjects
  broadcast.register(broadcaster, subj2)
  broadcast.send(broadcaster, Foo(2))
  process.receive(subj1, 100)
  |> expect.to_equal(Ok(Foo(2)))
  process.receive(subj2, 100)
  |> expect.to_equal(Ok(Foo(2)))

  // Expect second add to be ignored
  broadcast.register(broadcaster, subj1)
  broadcast.send(broadcaster, Foo(3))
  process.receive(subj1, 100)
  |> expect.to_equal(Ok(Foo(3)))
  process.receive(subj1, 100)
  |> expect.to_equal(Error(Nil))
  process.receive(subj2, 100)
  |> expect.to_equal(Ok(Foo(3)))

  // Expect unregister to work
  broadcast.unregister(broadcaster, subj1)
  broadcast.send(broadcaster, Foo(4))
  process.receive(subj1, 100)
  |> expect.to_equal(Error(Nil))
  process.receive(subj2, 100)
  |> expect.to_equal(Ok(Foo(4)))

  // Expect unregister to work again, leaving no subjects
  broadcast.unregister(broadcaster, subj2)
  broadcast.send(broadcaster, Foo(5))
  process.receive(subj1, 100)
  |> expect.to_equal(Error(Nil))
  process.receive(subj2, 100)
  |> expect.to_equal(Error(Nil))
}
