# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrefixedPublicId do
  describe '.generate' do
    it 'generates a ppid for a Server record' do
      server = create(:server)
      public_id = PublicId.from_uuid(server.uuid)

      ppid = described_class.generate(server)

      expect(ppid).to eq("server_#{public_id}")
    end

    it 'generates a ppid for a ServerVote record' do
      server_vote = create(:server_vote)
      public_id = PublicId.from_uuid(server_vote.uuid)

      ppid = described_class.generate(server_vote)

      expect(ppid).to eq("server_vote_#{public_id}")
    end

    it 'generates a ppid for a User record' do
      user = create(:user)
      public_id = PublicId.from_uuid(user.uuid)

      ppid = described_class.generate(user)

      expect(ppid).to eq("user_#{public_id}")
    end
  end

  describe '.parse' do
    it 'parses from a Server ppid' do
      prefix = "server"
      uuid = SecureRandom.uuid
      public_id = PublicId.from_uuid(uuid)
      ppid = "#{prefix}_#{public_id}"

      record_class, uuid = described_class.parse(ppid)

      expect(record_class).to eq(Server)
      expect(uuid).to eq(uuid)
    end

    it 'parses from a ServerVote ppid' do
      prefix = "server_vote"
      uuid = SecureRandom.uuid
      public_id = PublicId.from_uuid(uuid)
      ppid = "#{prefix}_#{public_id}"

      record_class, uuid = described_class.parse(ppid)

      expect(record_class).to eq(ServerVote)
      expect(uuid).to eq(uuid)
    end

    it 'parses from a User ppid' do
      prefix = "user"
      uuid = SecureRandom.uuid
      public_id = PublicId.from_uuid(uuid)
      ppid = "#{prefix}_#{public_id}"

      record_class, uuid = described_class.parse(ppid)

      expect(record_class).to eq(User)
      expect(uuid).to eq(uuid)
    end
  end

  describe '.find_record' do
    context 'when record is not found' do
      it 'returns nil' do
        ppid = "user_#{PublicId.from_uuid('00000000-0000-0000-0000-000000000000')}"

        user_found = described_class.find_record(ppid)

        expect(user_found).to be_nil
      end
    end

    context 'when record is found' do
      it 'returns the record' do
        user = create(:user)
        ppid = described_class.generate(user)

        user_found = described_class.find_record(ppid)

        expect(user_found).to eq(user)
      end
    end
  end

  describe '.record_exists?' do
    context 'when record is not found' do
      it 'returns false' do
        ppid = "user_#{PublicId.from_uuid('00000000-0000-0000-0000-000000000000')}"

        result = described_class.record_exists?(ppid)

        expect(result).to be(false)
      end
    end

    context 'when record is found' do
      it 'returns true' do
        user = create(:user)
        ppid = described_class.generate(user)

        result = described_class.record_exists?(ppid)

        expect(result).to be(true)
      end
    end
  end
end
