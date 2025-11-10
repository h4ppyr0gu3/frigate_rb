# frozen_string_literal: true

require "test_helper"

class EndpointsTest < Minitest::Test
  def test_known_endpoints
    assert_equal "/api/login", FrigateRb::Endpoints.login
    assert_equal "/api/version", FrigateRb::Endpoints.version
    assert_equal "/api/events", FrigateRb::Endpoints.events
    assert_equal "/api/event_ids", FrigateRb::Endpoints.event_ids
    assert_equal "/api/reviews/viewed", FrigateRb::Endpoints.multiple_reviewed
    assert_equal "/api/faces", FrigateRb::Endpoints.faces
    assert_equal "/api/stats", FrigateRb::Endpoints.stats
  end

  def test_dynamic_endpoints_with_params
    assert_equal "/api/events/123", FrigateRb::Endpoints.event(123)
    assert_equal "/api/review/abc", FrigateRb::Endpoints.review("abc")
    assert_equal "/api/cam1/latest.jpg", FrigateRb::Endpoints.latest_frame("cam1")
    assert_equal "/api/logs/go2rtc", FrigateRb::Endpoints.logs("go2rtc")
    assert_equal "/api/faces/jane/create", FrigateRb::Endpoints.create_face("jane")
    assert_equal "/api/review/event/evt_1", FrigateRb::Endpoints.review_from_event("evt_1")
  end
end
