# frozen_string_literal: true

require "test_helper"

class EventTest < Minitest::Test
  def setup
    @client = FrigateRb::Client.instance
    @client.session_cookie = "abc123"
    @client.session_expires_at = Time.now + 3600
  end

  def test_all_returns_collection_of_events
    stub_request(:get, "https://localhost:8971/api/events")
      .to_return(status: 200, body: '[{"id":"e1","label":"person"}]', headers: { "Content-Type" => "application/json" })

    res = FrigateRb::Event.all
    assert_kind_of FrigateRb::Collection, res
    assert_equal 1, res.size
    assert_kind_of FrigateRb::Types::Event, res[0]
    assert_equal "e1", res[0].id
  end

  def test_find_returns_event
    stub_request(:get, "https://localhost:8971/api/events/e2")
      .to_return(status: 200, body: '{"id":"e2","label":"car"}', headers: { "Content-Type" => "application/json" })

    ev = FrigateRb::Event.find("e2")
    assert_kind_of FrigateRb::Types::Event, ev
    assert_equal "e2", ev.id
  end

  def test_find_by_ids_joins_params
    stub_request(:get, "https://localhost:8971/api/event_ids?ids=e1,e2")
      .to_return(status: 200, body: '[{"id":"e1"},{"id":"e2"}]', headers: { "Content-Type" => "application/json" })

    res = FrigateRb::Event.find_by_ids(%w[e1 e2])
    assert_equal 2, res.size
    assert_equal ["e1", "e2"], res.pluck(:id)
  end

  def test_where_with_params
    stub_request(:get, "https://localhost:8971/api/events?label=dog")
      .to_return(status: 200, body: '[{"id":"e3","label":"dog"}]', headers: { "Content-Type" => "application/json" })

    res = FrigateRb::Event.where(label: "dog")
    assert_equal 1, res.size
    assert_equal "dog", res[0].label
  end
end
