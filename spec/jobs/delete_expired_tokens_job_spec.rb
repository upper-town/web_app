require 'rails_helper'

RSpec.describe DeleteExpiredTokensJob do
  describe '#perform' do
    it 'deletes all expired Token and AdminToken records' do
      token1 = create(:token, expires_at: 2.days.ago)
      token2 = create(:token, expires_at: 2.days.from_now)
      admin_token1 = create(:admin_token, expires_at: 2.days.ago)
      admin_token2 = create(:admin_token, expires_at: 2.days.from_now)

      expect do
        described_class.new.perform
      end.to(
        change(Token, :count).by(-1).and(
          change(AdminToken, :count).by(-1)
        )
      )

      expect(Token.find_by(id: token1.id)).to be_blank
      expect(Token.find_by(id: token2.id)).to eq(token2)
      expect(AdminToken.find_by(id: admin_token1.id)).to be_blank
      expect(AdminToken.find_by(id: admin_token2.id)).to eq(admin_token2)
    end
  end
end
