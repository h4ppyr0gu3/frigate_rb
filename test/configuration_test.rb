# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    # reset to defaults before each test
    FrigateRb.configure do |c|
      c.frigate_https_url = "https://localhost:8971"
      c.frigate_mqtt_url = "mqtt://localhost:1883"
      c.frigate_username = "admin"
      c.frigate_password = ""
      c.open_timeout = 5
      c.request_timeout = 15
      c.stream_timeout = 120
    end
  end

  def teardown
    FrigateRb.configure do |c|
      c.frigate_https_url = "https://localhost:8971"
      c.frigate_mqtt_url = "mqtt://localhost:1883"
      c.frigate_username = "admin"
      c.frigate_password = ""
      c.open_timeout = 5
      c.request_timeout = 15
      c.stream_timeout = 120
    end
  end

  def test_defaults
    cfg = FrigateRb::Configuration.new
    assert_equal "https://localhost:8971", cfg.frigate_https_url
    assert_equal "mqtt://localhost:1883", cfg.frigate_mqtt_url
    assert_equal "admin", cfg.frigate_username
    assert_equal "", cfg.frigate_password
    assert_equal 5, cfg.open_timeout
    assert_equal 15, cfg.request_timeout
    assert_equal 120, cfg.stream_timeout
  end

  def test_configure_block
    FrigateRb.configure do |c|
      c.frigate_https_url = "https://example"
      c.frigate_mqtt_url = "mqtt://example:1883"
      c.frigate_username = "user"
      c.frigate_password = "pw"
      c.open_timeout = 2
      c.request_timeout = 10
      c.stream_timeout = 90
    end

    cfg = FrigateRb.configuration
    assert_equal "https://example", cfg.frigate_https_url
    assert_equal "mqtt://example:1883", cfg.frigate_mqtt_url
    assert_equal "user", cfg.frigate_username
    assert_equal "pw", cfg.frigate_password
    assert_equal 2, cfg.open_timeout
    assert_equal 10, cfg.request_timeout
    assert_equal 90, cfg.stream_timeout
  end
end
