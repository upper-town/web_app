require 'rails_helper'

RSpec.describe RateLimiting::BasicRateLimiter do
  describe '#call and #uncall' do
    it 'returns success/failure accordingly' do
      rate_limiter = described_class.new('some_specific_key', 2, 1.hour, 'Some error message')

      result = rate_limiter.call
      expect(result.success?).to be(true)
      expect(Rails.cache.read('some_specific_key')).to eq(1)

      result = rate_limiter.call
      expect(result.success?).to be(true)
      expect(Rails.cache.read('some_specific_key')).to eq(2)

      result = rate_limiter.call
      expect(result.failure?).to be(true)
      expect(result.errors[:base]).to include(/Some error message\. Please try again .+/)
      expect(Rails.cache.read('some_specific_key')).to eq(3)

      result = rate_limiter.uncall
      expect(result.success?).to be(true)
      expect(Rails.cache.read('some_specific_key')).to eq(2)

      result = rate_limiter.uncall
      expect(result.success?).to be(true)
      expect(Rails.cache.read('some_specific_key')).to eq(1)

      result = rate_limiter.call
      expect(result.success?).to be(true)
      expect(Rails.cache.read('some_specific_key')).to eq(2)

      result = rate_limiter.call
      expect(result.failure?).to be(true)
      expect(result.errors[:base]).to include(/Some error message\. Please try again .+/)
      expect(Rails.cache.read('some_specific_key')).to eq(3)
    end
  end
end
