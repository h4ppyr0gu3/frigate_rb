# frozen_string_literal: true

require "test_helper"

class RegistryTest < Minitest::Test
  def teardown
    FrigateRb.reset!
  end

  def test_configure_with_name_creates_named_configuration
    FrigateRb.configure(:frigate) do |c|
      c.frigate_https_url = "https://nvr1:8971"
    end

    assert_equal "https://nvr1:8971", FrigateRb.configuration(:frigate).frigate_https_url
  end

  def test_configure_without_name_uses_default
    FrigateRb.configure do |c|
      c.frigate_https_url = "https://default:8971"
    end

    assert_equal "https://default:8971", FrigateRb.configuration.frigate_https_url
    assert_equal "https://default:8971", FrigateRb.configuration(:default).frigate_https_url
  end

  def test_client_returns_memoized_client
    client_a = FrigateRb.client(:frigate)
    client_b = FrigateRb.client(:frigate)

    assert_same client_a, client_b
  end

  def test_different_names_return_different_clients
    FrigateRb.configure(:frigate) { |c| c.frigate_https_url = "https://nvr1:8971" }
    FrigateRb.configure(:frigate2) { |c| c.frigate_https_url = "https://nvr2:8971" }

    refute_same FrigateRb.client(:frigate), FrigateRb.client(:frigate2)
    assert_equal "https://nvr1:8971", FrigateRb.client(:frigate).configuration.frigate_https_url
    assert_equal "https://nvr2:8971", FrigateRb.client(:frigate2).configuration.frigate_https_url
  end

  def test_clients_returns_hash_of_all_registered
    FrigateRb.configure(:frigate) { |c| c.frigate_https_url = "https://nvr1:8971" }
    FrigateRb.configure(:frigate2) { |c| c.frigate_https_url = "https://nvr2:8971" }

    FrigateRb.client(:frigate)
    FrigateRb.client(:frigate2)

    assert_kind_of Hash, FrigateRb.clients
    assert_includes FrigateRb.clients.keys, :frigate
    assert_includes FrigateRb.clients.keys, :frigate2
  end

  def test_client_instance_aliases_default_client
    assert_same FrigateRb::Client.instance, FrigateRb.client(:default)
  end

  def test_unregister_removes_client_and_configuration
    FrigateRb.configure(:frigate) { |c| c.frigate_https_url = "https://nvr1:8971" }
    FrigateRb.client(:frigate)

    FrigateRb.unregister(:frigate)

    refute_includes FrigateRb.clients, :frigate
    refute_includes FrigateRb.configurations, :frigate
  end

  def test_unregister_then_client_creates_fresh_client
    FrigateRb.configure(:frigate) { |c| c.frigate_https_url = "https://nvr1:8971" }
    old_client = FrigateRb.client(:frigate)

    FrigateRb.unregister(:frigate)
    new_client = FrigateRb.client(:frigate)

    refute_same old_client, new_client
  end

  def test_reload_rebuilds_client_with_new_config
    FrigateRb.configure(:frigate) { |c| c.frigate_https_url = "https://nvr1:8971" }
    old_client = FrigateRb.client(:frigate)

    FrigateRb.reload(:frigate) { |c| c.frigate_https_url = "https://nvr1-updated:8971" }
    new_client = FrigateRb.client(:frigate)

    refute_same old_client, new_client
    assert_equal "https://nvr1-updated:8971", new_client.configuration.frigate_https_url
  end

  def test_reload_without_block_still_rebuilds
    FrigateRb.configure(:frigate) { |c| c.frigate_https_url = "https://nvr1:8971" }
    old_client = FrigateRb.client(:frigate)

    FrigateRb.reload(:frigate)
    new_client = FrigateRb.client(:frigate)

    refute_same old_client, new_client
    assert_equal "https://nvr1:8971", new_client.configuration.frigate_https_url
  end

  def test_reset_clears_everything
    FrigateRb.configure(:frigate) { |c| c.frigate_https_url = "https://nvr1:8971" }
    FrigateRb.configure(:frigate2) { |c| c.frigate_https_url = "https://nvr2:8971" }
    FrigateRb.client(:frigate)
    FrigateRb.client(:frigate2)

    FrigateRb.reset!

    assert_empty FrigateRb.clients
    assert_empty FrigateRb.configurations
  end

  def test_each_client_has_own_cookie_jar
    FrigateRb.configure(:frigate) { |c| c.frigate_https_url = "https://nvr1:8971" }
    FrigateRb.configure(:frigate2) { |c| c.frigate_https_url = "https://nvr2:8971" }

    refute_same FrigateRb.client(:frigate).cookie_jar, FrigateRb.client(:frigate2).cookie_jar
  end
end
