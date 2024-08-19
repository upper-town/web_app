# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminSession do
  describe 'associations' do
    it 'belongs to admin_user' do
      admin_session = create(:admin_session)

      expect(admin_session.admin_user).to be_present
    end
  end

  describe '#expired?' do
    context 'when expires_at is the current time' do
      it 'returns true' do
        freeze_time do
          admin_session = create(:admin_session, expires_at: Time.current)

          expect(admin_session.expired?).to be(true)
        end
      end
    end

    context 'when expires_at is less than the current time' do
      it 'returns true' do
        freeze_time do
          admin_session = create(:admin_session, expires_at: 1.second.ago)

          expect(admin_session.expired?).to be(true)
        end
      end
    end

    context 'when expires_at is greater than the current time' do
      it 'returns false' do
        freeze_time do
          admin_session = create(:admin_session, expires_at: 1.second.from_now)

          expect(admin_session.expired?).to be(false)
        end
      end
    end
  end
end
