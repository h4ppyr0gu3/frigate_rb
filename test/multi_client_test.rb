# frozen_string_literal: true

require "test_helper"

class MultiClientEventTest < Minitest::Test
  def teardown
    FrigateRb.reset!
  end

  def setup
    FrigateRb.configure(:frigate) do |c|
      c.frigate_https_url = "https://nvr1:8971"
      c.frigate_username = "admin"
      c.frigate_password = "secret"
    end
    FrigateRb.configure(:frigate2) do |c|
      c.frigate_https_url = "https://nvr2:8971"
      c.frigate_username = "admin"
      c.frigate_password = "other"
    end

    @client1 = FrigateRb.client(:frigate)
    @client1.session_cookie = "token1"
    @client1.session_expires_at = Time.now + 3600

    @client2 = FrigateRb.client(:frigate2)
    @client2.session_cookie = "token2"
    @client2.session_expires_at = Time.now + 3600
  end

  def test_find_uses_specified_client
    stub_request(:get, "https://nvr2:8971/api/events/e99")
      .to_return(status: 200, body: '{"id":"e99","label":"car"}', headers: { "Content-Type" => "application/json" })

    event = FrigateRb::Event.find("e99", client: @client2)
    assert_equal "e99", event.id
    assert_same @client2, event.client
  end

  def test_event_mark_as_reviewed_uses_fetch_client
    # find the event on :frigate2
    stub_request(:get, "https://nvr2:8971/api/events/e50")
      .to_return(status: 200, body: '{"id":"e50","label":"person"}', headers: { "Content-Type" => "application/json" })

    event = FrigateRb::Event.find("e50", client: @client2)
    assert_same @client2, event.client

    # mark_as_reviewed should hit :frigate2, not :frigate
    stub_request(:get, "https://nvr2:8971/api/review/event/e50")
      .to_return(status: 200, body: '{"id":"r50","start_time":1700000000,"end_time":1700003600}', headers: { "Content-Type" => "application/json" })

    stub_request(:post, "https://nvr2:8971/api/reviews/viewed")
      .with(body: '{"ids":["r50"]}')
      .to_return(status: 200, body: '{"success":true,"message":"ok"}', headers: { "Content-Type" => "application/json" })

    result = event.mark_as_reviewed
    assert_equal true, result.success

    # Ensure :frigate2 was hit, not :frigate
    assert_requested :get, "https://nvr2:8971/api/review/event/e50", times: 1
    assert_requested :post, "https://nvr2:8971/api/reviews/viewed", times: 1
    assert_not_requested :get, "https://nvr1:8971/api/review/event/e50"
  end

  def test_all_with_client_uses_specified_client
    stub_request(:get, "https://nvr1:8971/api/events")
      .to_return(status: 200, body: '[{"id":"e1","label":"person"}]', headers: { "Content-Type" => "application/json" })

    collection = FrigateRb::Event.all(client: @client1)
    assert_equal 1, collection.size
    assert_same @client1, collection[0].client
  end

  def test_where_with_client_and_kwargs
    stub_request(:get, "https://nvr1:8971/api/events?label=dog")
      .to_return(status: 200, body: '[{"id":"e3","label":"dog"}]', headers: { "Content-Type" => "application/json" })

    res = FrigateRb::Event.where(label: "dog", client: @client1)
    assert_equal "dog", res[0].label
    assert_same @client1, res[0].client
  end

  def test_review_events_uses_same_client
    # fetch a review from :frigate2
    stub_request(:get, "https://nvr2:8971/api/review/r77")
      .to_return(status: 200, body: '{"id":"r77","start_time":1700000000,"end_time":1700003600,"data":{"detections":["e1","e2"]}}', headers: { "Content-Type" => "application/json" })

    review = FrigateRb::Review.find("r77", client: @client2)
    assert_same @client2, review.client

    # review.events should call Event.find_by_ids on :frigate2
    stub_request(:get, "https://nvr2:8971/api/event_ids?ids=e1,e2")
      .to_return(status: 200, body: '[{"id":"e1"},{"id":"e2"}]', headers: { "Content-Type" => "application/json" })

    events = review.events
    assert_equal 2, events.size
    assert_same @client2, events[0].client
    assert_same @client2, events[1].client
  end
end
