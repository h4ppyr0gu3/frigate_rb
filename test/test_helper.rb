# frozen_string_literal: true

require "minitest/autorun"
require "webmock/minitest"
require "vcr"

require "frigate_rb"

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |c|
  c.cassette_library_dir = File.expand_path("fixtures/vcr_cassettes", __dir__)
  c.hook_into :webmock
  c.default_cassette_options = { match_requests_on: %i[method uri body], record: :none }
  c.allow_http_connections_when_no_cassette = false
end
# frozen_string_literal: true

require "minitest/autorun"
require "webmock/minitest"
require "vcr"

require "frigate_rb"

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |c|
  c.cassette_library_dir = File.expand_path("fixtures/vcr_cassettes", __dir__)
  c.hook_into :webmock
  c.default_cassette_options = {
    match_requests_on: %i[method uri body],
    record: :none
  }
  c.allow_http_connections_when_no_cassette = true
end
