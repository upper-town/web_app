# frozen_string_literal: true

require "test_helper"
require "minitest/rails/capybara"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  register_spec_type(self) do |_desc, *addl|
    addl.include?(:system)
  end

  include CapybaraTestSetup
end
