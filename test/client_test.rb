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
      assert client.session_expires_at > Time.now
    end
  end

  def test_session_valid_requires_future_expiry_beyond_skew
    client = FrigateRb::Client.instance
    client.session_cookie = "abc123"

    client.session_expires_at = Time.now + FrigateRb::Client::SESSION_RENEWAL_SKEW + 30
    assert client.session_valid?

    client.session_expires_at = Time.now + (FrigateRb::Client::SESSION_RENEWAL_SKEW / 2)
    refute client.session_valid?

    client.session_expires_at = Time.now - 1
    refute client.session_valid?

    client.session_cookie = nil
    client.session_expires_at = Time.now + 3600
    refute client.session_valid?
  end
end
