# frozen_string_literal: true

require "test_helper"
require "tempfile"

class FacesTest < Minitest::Test
  def setup
    FrigateRb.configure do |config|
      config.frigate_https_url = "https://localhost:8971"
      config.frigate_username = "admin"
      config.frigate_password = "secret"
    end
    @client = FrigateRb::Client.instance
    @client.session_cookie = "abc123"
    @client.session_expires_at = Time.now + 3600
  end

  def test_all
    stub_request(:get, "https://localhost:8971/api/faces")
      .to_return(status: 200, body: '[{"name":"jane"}]', headers: { "Content-Type" => "application/json" })

    res = FrigateRb::Faces.all
    assert_equal 1, res.size
    assert_equal "jane", res[0].name
  end

  def test_create
    stub_request(:post, "https://localhost:8971/api/faces/jane/create")
      .to_return(status: 200, body: '{"name":"jane"}', headers: { "Content-Type" => "application/json" })

    face = FrigateRb::Faces.create("jane")
    assert_equal "jane", face.name
  end

  def test_train
    stub_request(:get, "https://localhost:8971/api/faces/train/jane/classify")
      .to_return(status: 200, body: '{"name":"jane"}', headers: { "Content-Type" => "application/json" })

    res = FrigateRb::Faces.train("jane")
    assert_equal "jane", res.name
  end

  def test_register_multipart
    stub_request(:post, "https://localhost:8971/api/faces/jane/register")
      .to_return(status: 200, body: '{"name":"jane"}', headers: { "Content-Type" => "application/json" })

    Tempfile.create(["face", ".jpg"]) do |tmp|
      tmp.write("data")
      tmp.rewind
      face = FrigateRb::Faces.register("jane", tmp)
      assert_equal "jane", face.name
    end
  end
end
