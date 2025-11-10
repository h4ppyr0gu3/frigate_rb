# frozen_string_literal: true

require "test_helper"

class ClientTest < Minitest::Test
  def setup
    FrigateRb.configure do |config|
      config.frigate_https_url = "https://localhost:8971"
      config.frigate_username = "admin"
      config.frigate_password = "secret"
    end
  end

  def test_authenticate_sets_session_cookie_with_vcr
    VCR.use_cassette("client_authenticate") do
      client = FrigateRb::Client.instance
      client.session_cookie = nil
      client.session_expires_at = Time.at(0)

      conn = client.authenticate

      assert conn, "expected a Faraday connection to be returned"
      refute_nil client.session_cookie
      assert_equal "abc123", client.session_cookie
    end
  end
end
