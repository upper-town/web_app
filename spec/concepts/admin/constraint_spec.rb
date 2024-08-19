# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Constraint do
  describe '#matches?' do
    context 'when admin_user is signed_in' do
      it 'returns true' do
        admin_user = create(:admin_user)
        request = build_request(admin_user, signed_in: true)

        expect(described_class.new.matches?(request)).to be(true)
      end
    end

    context 'when admin_user is not signed_in' do
      it 'returns false' do
        admin_user = create(:admin_user)
        request = build_request(admin_user, signed_in: false)

        expect(described_class.new.matches?(request)).to be(false)
      end
    end
  end

  def build_request(admin_user, signed_in:)
    request = ActionDispatch::Request.new({})

    if signed_in
      admin_session = create(:admin_session, admin_user: admin_user, expires_at: 1.month.from_now)
      request.cookie_jar['admin_session'] = { value: "#{admin_user.id}:#{admin_session.token}" }
    end

    request
  end
end
