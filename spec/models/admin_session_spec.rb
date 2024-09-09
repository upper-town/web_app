# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_sessions
#
#  id              :bigint           not null, primary key
#  expires_at      :datetime         not null
#  remote_ip       :string           not null
#  token_digest    :string           not null
#  token_last_four :string           not null
#  user_agent      :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  admin_user_id   :bigint           not null
#
# Indexes
#
#  index_admin_sessions_on_admin_user_id  (admin_user_id)
#  index_admin_sessions_on_token_digest   (token_digest) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
require 'rails_helper'

RSpec.describe AdminSession do
  describe 'associations' do
    it 'belongs to admin_user' do
      admin_session = create(:admin_session)

      expect(admin_session.admin_user).to be_present
    end
  end

  describe '.find_by_token' do
    context 'when token is blank' do
      it 'returns nil' do
        expect(described_class.find_by_token(' ')).to be_nil
      end
    end

    context 'when AdminSession is not found' do
      it 'returns nil' do
        expect(described_class.find_by_token('abcdef123456')).to be_nil
      end
    end

    context 'when AdminSession is found' do
      it 'returns AdminSession record' do
        admin_session = create(:admin_session, token_digest: TokenGenerator::AdminSession.digest('abcdef123456'))

        expect(described_class.find_by_token('abcdef123456')).to eq(admin_session)
      end
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
