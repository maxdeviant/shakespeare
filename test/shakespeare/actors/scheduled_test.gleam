import birl
import gleeunit/should
import shakespeare/actors/scheduled.{Daily, Hourly}

pub fn scheduled_next_occurrence_at_hourly_test() {
  let assert Ok(now) = birl.parse("2024-04-07T15:01:51.248Z")
  scheduled.next_occurrence_at(now, Hourly(30, 0))
  |> birl.to_iso8601
  |> should.equal("2024-04-07T15:30:00.000Z")

  let assert Ok(now) = birl.parse("2024-04-07T15:31:51.248Z")
  scheduled.next_occurrence_at(now, Hourly(30, 0))
  |> birl.to_iso8601
  |> should.equal("2024-04-07T16:30:00.000Z")
}

pub fn scheduled_next_occurrence_at_daily_test() {
  let assert Ok(now) = birl.parse("2024-04-07T15:59:51.248Z")
  scheduled.next_occurrence_at(now, Daily(16, 0, 0))
  |> birl.to_iso8601
  |> should.equal("2024-04-07T16:00:00.000Z")

  let assert Ok(now) = birl.parse("2024-04-07T16:01:51.248Z")
  scheduled.next_occurrence_at(now, Daily(16, 0, 0))
  |> birl.to_iso8601
  |> should.equal("2024-04-08T16:00:00.000Z")
}
