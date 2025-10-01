# frozen_string_literal: true

Dir[File.join(__dir__, "types", "*.rb")].sort.each { |file| require file }

module FrigateRb
  module Types
  end
end
