# frozen_string_literal: true

require "test_helper"

class InfoTest < Minitest::Test
  def setup
    @client = FrigateRb::Client.instance
    @client.session_cookie = "abc123"
    @client.session_expires_at = Time.now + 3600
  end

  def test_stats
    stub_request(:get, "https://localhost:8971/api/stats")
      .to_return(status: 200, body: '{"uptime": 100}', headers: { "Content-Type" => "application/json" })

    stats = FrigateRb::Info.stats
    assert_equal 100, stats[:uptime]
  end

  def test_logs
    stub_request(:get, "https://localhost:8971/api/logs/frigate")
      .to_return(status: 200, body: '{"lines": ["a", "b"]}', headers: { "Content-Type" => "application/json" })

    logs = FrigateRb::Info.logs("frigate")
    assert_equal ["a", "b"], logs[:lines]
  end
end
