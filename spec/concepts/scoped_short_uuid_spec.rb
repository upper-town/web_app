# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScopedShortUuid do
  describe '.generate' do
    it 'generates a ssuuid for a Server record' do
      server = create(:server)
      short_uuid = ShortUuid.from_uuid(server.uuid)

      ssuuid = described_class.generate(server)

      expect(ssuuid).to eq("server_#{short_uuid}")
    end

    it 'generates a ssuuid for a ServerVote record' do
      server_vote = create(:server_vote)
      short_uuid = ShortUuid.from_uuid(server_vote.uuid)

      ssuuid = described_class.generate(server_vote)

      expect(ssuuid).to eq("server_vote_#{short_uuid}")
    end

    it 'generates a ssuuid for a User record' do
      user = create(:user)
      short_uuid = ShortUuid.from_uuid(user.uuid)

      ssuuid = described_class.generate(user)

      expect(ssuuid).to eq("user_#{short_uuid}")
    end
  end

  describe '.parse' do
    it 'parses from a Server ssuuid' do
      scope = 'server'
      uuid = SecureRandom.uuid
      short_uuid = ShortUuid.from_uuid(uuid)
      ssuuid = "#{scope}_#{short_uuid}"

      parsed_record_class, parsed_uuid = described_class.parse(ssuuid)

      expect(parsed_record_class).to eq(Server)
      expect(parsed_uuid).to eq(uuid)
    end

    it 'parses from a ServerVote ssuuid' do
      scope = 'server_vote'
      uuid = SecureRandom.uuid
      short_uuid = ShortUuid.from_uuid(uuid)
      ssuuid = "#{scope}_#{short_uuid}"

      parsed_record_class, parsed_uuid = described_class.parse(ssuuid)

      expect(parsed_record_class).to eq(ServerVote)
      expect(parsed_uuid).to eq(uuid)
    end

    it 'parses from a User ssuuid' do
      scope = 'user'
      uuid = SecureRandom.uuid
      short_uuid = ShortUuid.from_uuid(uuid)
      ssuuid = "#{scope}_#{short_uuid}"

      parsed_record_class, parsed_uuid = described_class.parse(ssuuid)

      expect(parsed_record_class).to eq(User)
      expect(parsed_uuid).to eq(uuid)
    end
  end

  describe '.find_record' do
    context 'when record is not found' do
      it 'returns nil' do
        ssuuid = "user_#{ShortUuid.from_uuid('00000000-0000-0000-0000-000000000000')}"

        user_found = described_class.find_record(ssuuid)

        expect(user_found).to be_nil
      end
    end

    context 'when record is found' do
      it 'returns the record' do
        user = create(:user)
        ssuuid = described_class.generate(user)

        user_found = described_class.find_record(ssuuid)

        expect(user_found).to eq(user)
      end
    end
  end

  describe '.record_exists?' do
    context 'when record is not found' do
      it 'returns false' do
        ssuuid = "user_#{ShortUuid.from_uuid('00000000-0000-0000-0000-000000000000')}"

        result = described_class.record_exists?(ssuuid)

        expect(result).to be(false)
      end
    end

    context 'when record is found' do
      it 'returns true' do
        user = create(:user)
        ssuuid = described_class.generate(user)

        result = described_class.record_exists?(ssuuid)

        expect(result).to be(true)
      end
    end
  end
end
