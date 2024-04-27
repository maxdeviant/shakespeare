import birl.{Fri, Sun}
import shakespeare/actors/scheduled.{Daily, Hourly, Weekly}
import startest/expect

pub fn scheduled_next_occurrence_at_hourly_test() {
  let assert Ok(now) = birl.parse("2024-04-07T15:01:51.248Z")
  scheduled.next_occurrence_at(now, Hourly(30, 0))
  |> birl.to_iso8601
  |> expect.to_equal("2024-04-07T15:30:00.000Z")

  let assert Ok(now) = birl.parse("2024-04-07T15:31:51.248Z")
  scheduled.next_occurrence_at(now, Hourly(30, 0))
  |> birl.to_iso8601
  |> expect.to_equal("2024-04-07T16:30:00.000Z")
}

pub fn scheduled_next_occurrence_at_daily_test() {
  let assert Ok(now) = birl.parse("2024-04-07T15:59:51.248Z")
  scheduled.next_occurrence_at(now, Daily(16, 0, 0))
  |> birl.to_iso8601
  |> expect.to_equal("2024-04-07T16:00:00.000Z")

  let assert Ok(now) = birl.parse("2024-04-07T16:01:51.248Z")
  scheduled.next_occurrence_at(now, Daily(16, 0, 0))
  |> birl.to_iso8601
  |> expect.to_equal("2024-04-08T16:00:00.000Z")
}

pub fn scheduled_next_occurrence_at_weekly_test() {
  let assert Ok(now) = birl.parse("2024-04-22T19:37:40.916Z")
  scheduled.next_occurrence_at(now, Weekly(Fri, 18, 0, 0))
  |> birl.to_iso8601
  |> expect.to_equal("2024-04-26T18:00:00.000Z")

  let assert Ok(now) = birl.parse("2024-04-26T16:37:40.916Z")
  scheduled.next_occurrence_at(now, Weekly(Fri, 18, 0, 0))
  |> birl.to_iso8601
  |> expect.to_equal("2024-04-26T18:00:00.000Z")

  let assert Ok(now) = birl.parse("2024-04-27T19:37:40.916Z")
  scheduled.next_occurrence_at(now, Weekly(Sun, 13, 0, 0))
  |> birl.to_iso8601
  |> expect.to_equal("2024-04-28T13:00:00.000Z")

  let assert Ok(now) = birl.parse("2024-04-27T19:37:40.916Z")
  scheduled.next_occurrence_at(now, Weekly(Fri, 18, 0, 0))
  |> birl.to_iso8601
  |> expect.to_equal("2024-05-03T18:00:00.000Z")
}
