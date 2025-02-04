# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerVote do
  describe 'associations' do
    it 'belongs to server' do
      server_vote = create(:server_vote)

      expect(server_vote.server).to be_present
    end

    it 'belongs to game' do
      server_vote = create(:server_vote)

      expect(server_vote.game).to be_present
    end

    it 'belongs to account optionally' do
      server_vote = create(:server_vote)

      expect(server_vote.account).to be_blank

      server_vote = create(:server_vote, account: create(:account))

      expect(server_vote.account).to be_present
    end
  end

  describe 'validations' do
    it 'validates country_code' do
      server_vote = build(:server_vote, country_code: '123456')
      server_vote.validate

      expect(server_vote.errors.of_kind?(:country_code, :inclusion)).to be(true)
    end

    it 'validates server_available' do
      server = create(:server, archived_at: Time.current)
      server_vote = build(:server_vote, server: server)
      server_vote.validate

      expect(server_vote.errors.of_kind?(:server, 'cannot be archived')).to be(true)

      server = create(:server, marked_for_deletion_at: Time.current)
      server_vote = build(:server_vote, server: server)
      server_vote.validate

      expect(server_vote.errors.of_kind?(:server, 'cannot be marked_for_deletion')).to be(true)

      server = create(:server)
      server_vote = build(:server_vote, server: server)
      server_vote.validate

      expect(server_vote.errors.key?(:server)).to be(false)
    end
  end
end
