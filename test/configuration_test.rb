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
    end
  end

  def teardown
    FrigateRb.configure do |c|
      c.frigate_https_url = "https://localhost:8971"
      c.frigate_mqtt_url = "mqtt://localhost:1883"
      c.frigate_username = "admin"
      c.frigate_password = ""
    end
  end

  def test_defaults
    cfg = FrigateRb.configuration
    assert_equal "https://localhost:8971", cfg.frigate_https_url
    assert_equal "mqtt://localhost:1883", cfg.frigate_mqtt_url
    assert_equal "admin", cfg.frigate_username
    assert_equal "", cfg.frigate_password
  end

  def test_configure_block
    FrigateRb.configure do |c|
      c.frigate_https_url = "https://example"
      c.frigate_mqtt_url = "mqtt://example:1883"
      c.frigate_username = "user"
      c.frigate_password = "pw"
    end

    cfg = FrigateRb.configuration
    assert_equal "https://example", cfg.frigate_https_url
    assert_equal "mqtt://example:1883", cfg.frigate_mqtt_url
    assert_equal "user", cfg.frigate_username
    assert_equal "pw", cfg.frigate_password
  end
end
