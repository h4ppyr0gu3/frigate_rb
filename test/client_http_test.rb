# frozen_string_literal: true

require "test_helper"

class ClientHttpTest < Minitest::Test
  def setup
    FrigateRb.configure do |config|
      config.frigate_https_url = "https://localhost:8971"
      config.frigate_username = "admin"
      config.frigate_password = "secret"
    end

    # Reset client state
    @client = FrigateRb::Client.instance
    @client.session_cookie = "abc123"
    @client.session_expires_at = Time.now + 3600
  end

  def test_get_uses_base_url_and_returns_json
    stub_request(:get, "https://localhost:8971/api/version")
      .to_return(status: 200, body: '{"version":"0.13.1"}', headers: { "Content-Type" => "application/json" })

    resp = @client.get(FrigateRb::Endpoints.version)
    assert_equal 200, resp.status
    assert_equal({ version: "0.13.1" }, resp.body)
  end

  def test_post_json_body
    stub_request(:post, "https://localhost:8971/api/reviews/viewed")
      .with(body: '{"ids":[1,2,3]}')
      .to_return(status: 204, body: "", headers: {})

    resp = @client.post(FrigateRb::Endpoints.multiple_reviewed, { ids: [1, 2, 3] }.to_json, { "Content-Type" => "application/json" })
    assert_equal 204, resp.status
  end
end
