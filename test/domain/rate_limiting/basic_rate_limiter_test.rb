# frozen_string_literal: true

require "test_helper"

class RateLimiting::BasicRateLimiterTest < ActiveSupport::TestCase
  let(:described_class) { RateLimiting::BasicRateLimiter }

  describe "#call and #uncall" do
    it "returns success/failure accordingly" do
      rate_limiter = described_class.new("some_specific_key", 2, 1.hour, "Some error message")

      result = rate_limiter.call
      assert(result.success?)
      assert_equal(1, Rails.cache.read("some_specific_key"))

      result = rate_limiter.call
      assert(result.success?)
      assert_equal(2, Rails.cache.read("some_specific_key"))

      result = rate_limiter.call
      assert(result.failure?)
      assert(result.errors[:base].any? { it.match?(/Some error message\. Please try again .+/) })
      assert_equal(3, Rails.cache.read("some_specific_key"))

      result = rate_limiter.uncall
      assert(result.success?)
      assert_equal(2, Rails.cache.read("some_specific_key"))

      result = rate_limiter.uncall
      assert(result.success?)
      assert_equal(1, Rails.cache.read("some_specific_key"))

      result = rate_limiter.call
      assert(result.success?)
      assert_equal(2, Rails.cache.read("some_specific_key"))

      result = rate_limiter.call
      assert(result.failure?)
      assert(result.errors[:base].any? { it.match?(/Some error message\. Please try again .+/) })
      assert_equal(3, Rails.cache.read("some_specific_key"))
    end
  end
end
