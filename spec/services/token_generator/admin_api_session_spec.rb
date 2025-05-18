require 'rails_helper'

RSpec.describe TokenGenerator::AdminApiSession do
  let(:base58_chars) { 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789' }

  describe '.generate' do
    it 'generates a random token and returns it with digest and last four' do
      secret = Rails.application.key_generator.generate_key(ENV.fetch('TOKEN_ADMIN_API_SESSION_SALT'))

      token, token_digest, token_last_four = described_class.generate
      expect(token).to match(/\A[#{base58_chars}]{48}\z/)
      expect(token_digest).to eq(OpenSSL::HMAC.hexdigest('sha256', secret, token))
      expect(token_last_four).to eq(token.last(4))
    end
  end

  describe '.digest' do
    it 'returns HMAC-signed digest of a token' do
      secret = Rails.application.key_generator.generate_key(ENV.fetch('TOKEN_ADMIN_API_SESSION_SALT'))
      token = 'abcdef123456'
      expect_token_digest = OpenSSL::HMAC.hexdigest('sha256', secret, token)

      token_digest = described_class.digest(token)

      expect(token_digest).to eq(expect_token_digest)
    end
  end
end
