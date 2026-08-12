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

  def test_get_renews_session_when_expired
    @client.session_expires_at = Time.now - 1

    stub_login(token: "renewed")
    stub_request(:get, "https://localhost:8971/api/version")
      .to_return(status: 200, body: '{"version":"0.13.1"}', headers: { "Content-Type" => "application/json" })

    resp = @client.get(FrigateRb::Endpoints.version)

    assert_equal 200, resp.status
    assert_equal "renewed", @client.session_cookie
    assert_requested :post, "https://localhost:8971/api/login", times: 1
  end

  def test_get_renews_session_within_renewal_skew
    @client.session_expires_at = Time.now + (FrigateRb::Client::SESSION_RENEWAL_SKEW / 2)

    stub_login(token: "skew-renewed")
    stub_request(:get, "https://localhost:8971/api/version")
      .to_return(status: 200, body: '{"version":"0.13.1"}', headers: { "Content-Type" => "application/json" })

    resp = @client.get(FrigateRb::Endpoints.version)

    assert_equal 200, resp.status
    assert_equal "skew-renewed", @client.session_cookie
    assert_requested :post, "https://localhost:8971/api/login", times: 1
  end

  def test_get_retries_once_after_401
    stub_request(:get, "https://localhost:8971/api/version")
      .to_return(
        { status: 401, body: "unauthorized", headers: { "Content-Type" => "text/plain" } },
        { status: 200, body: '{"version":"0.13.1"}', headers: { "Content-Type" => "application/json" } }
      )
    stub_login(token: "after-401")

    resp = @client.get(FrigateRb::Endpoints.version)

    assert_equal 200, resp.status
    assert_equal({ version: "0.13.1" }, resp.body)
    assert_equal "after-401", @client.session_cookie
    assert_requested :get, "https://localhost:8971/api/version", times: 2
    assert_requested :post, "https://localhost:8971/api/login", times: 1
  end

  def test_get_does_not_retry_after_second_401
    stub_request(:get, "https://localhost:8971/api/version")
      .to_return(status: 401, body: "unauthorized", headers: { "Content-Type" => "text/plain" })
    stub_login(token: "still-bad")

    resp = @client.get(FrigateRb::Endpoints.version)

    assert_equal 401, resp.status
    assert_requested :get, "https://localhost:8971/api/version", times: 2
    assert_requested :post, "https://localhost:8971/api/login", times: 1
  end

  def test_stream_retries_once_after_401
    stub_request(:get, "https://localhost:8971/api/events/abc/clip.mp4")
      .to_return(
        { status: 401, body: "unauthorized", headers: { "Content-Type" => "text/plain" } },
        { status: 200, body: "video-bytes", headers: { "Content-Type" => "video/mp4" } }
      )
    stub_login(token: "stream-401")

    status = nil
    body = +""
    @client.stream("/api/events/abc/clip.mp4") do |headers, enumerator|
      status = headers["status"]
      enumerator.each { |chunk| body << chunk }
    end

    assert_equal 200, status
    assert_equal "video-bytes", body
    assert_equal "stream-401", @client.session_cookie
    assert_requested :get, "https://localhost:8971/api/events/abc/clip.mp4", times: 2
    assert_requested :post, "https://localhost:8971/api/login", times: 1
  end

  private

  def stub_login(token:)
    stub_request(:post, "https://localhost:8971/api/login")
      .with(body: '{"user":"admin","password":"secret"}')
      .to_return(
        status: 200,
        body: '{"success":true}',
        headers: {
          "Content-Type" => "application/json",
          "Set-Cookie" => "frigate_token=#{token}; Path=/; HttpOnly; Secure; Expires=Wed, 31 Dec 2099 23:59:59 GMT"
        }
      )
  end
end
