# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersQuery do
  describe '#call' do
    it 'returns all users ordered by id desc' do
      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user)

      expect(described_class.new.call).to eq([
        user3,
        user2,
        user1,
      ])
    end
  end
end
