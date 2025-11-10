# frozen_string_literal: true

require "test_helper"

class ReviewTest < Minitest::Test
  def setup
    @client = FrigateRb::Client.instance
    @client.session_cookie = "abc123"
    @client.session_expires_at = Time.now + 3600
  end

  def test_all
    stub_request(:get, "https://localhost:8971/api/review")
      .to_return(status: 200, body: '[{"id":"r1","message":"ok","start_time":1700000000,"end_time":1700003600}]', headers: { "Content-Type" => "application/json" })

    res = FrigateRb::Review.all
    assert_equal 1, res.size
  end

  def test_find
    stub_request(:get, "https://localhost:8971/api/review/r2")
      .to_return(status: 200, body: '{"id":"r2","message":"ok","start_time":1700000000,"end_time":1700003600}', headers: { "Content-Type" => "application/json" })

    review = FrigateRb::Review.find("r2")
    assert_equal "r2", review.id
  end

  def test_where
    stub_request(:get, "https://localhost:8971/api/review?label=person")
      .to_return(status: 200, body: '[{"id":"r3","start_time":1700000000,"end_time":1700003600}]', headers: { "Content-Type" => "application/json" })

    res = FrigateRb::Review.where(label: "person")
    assert_equal 1, res.size
  end

  def test_from_event
    stub_request(:get, "https://localhost:8971/api/review/event/e1")
      .to_return(status: 200, body: '{"id":"r4","start_time":1700000000,"end_time":1700003600}', headers: { "Content-Type" => "application/json" })

    review = FrigateRb::Review.from_event("e1")
    assert_equal "r4", review.id
  end

  def test_multiple_reviewed
    stub_request(:post, "https://localhost:8971/api/reviews/viewed")
      .with(body: '{"ids":["r4","r5"]}')
      .to_return(status: 200, body: '{"success":true,"message":"ok"}', headers: { "Content-Type" => "application/json" })

    res = FrigateRb::Review.multiple_reviewed(%w[r4 r5])
    assert_equal true, res.success
  end
end
