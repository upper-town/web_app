# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScopedShortUuid do
  describe '.generate' do
    it 'generates a ssuuid for a App record' do
      app = create(:app)
      short_uuid = ShortUuid.from_uuid(app.uuid)

      ssuuid = described_class.generate(app)

      expect(ssuuid).to eq("app_#{short_uuid}")
    end

    it 'generates a ssuuid for a Server record' do
      server = create(:server)
      short_uuid = ShortUuid.from_uuid(server.uuid)

      ssuuid = described_class.generate(server)

      expect(ssuuid).to eq("server_#{short_uuid}")
    end

    it 'generates a ssuuid for a UserAccount record' do
      user_account = create(:user_account)
      short_uuid = ShortUuid.from_uuid(user_account.uuid)

      ssuuid = described_class.generate(user_account)

      expect(ssuuid).to eq("user_account_#{short_uuid}")
    end
  end

  describe '.parse' do
    it 'parses from a App ssuuid' do
      scope = 'app'
      uuid = SecureRandom.uuid
      short_uuid = ShortUuid.from_uuid(uuid)
      ssuuid = "#{scope}_#{short_uuid}"

      parsed_record_class, parsed_uuid = described_class.parse(ssuuid)

      expect(parsed_record_class).to eq(App)
      expect(parsed_uuid).to eq(uuid)
    end

    it 'parses from a Server ssuuid' do
      scope = 'server'
      uuid = SecureRandom.uuid
      short_uuid = ShortUuid.from_uuid(uuid)
      ssuuid = "#{scope}_#{short_uuid}"

      parsed_record_class, parsed_uuid = described_class.parse(ssuuid)

      expect(parsed_record_class).to eq(Server)
      expect(parsed_uuid).to eq(uuid)
    end

    it 'parses from a UserAccount ssuuid' do
      scope = 'user_account'
      uuid = SecureRandom.uuid
      short_uuid = ShortUuid.from_uuid(uuid)
      ssuuid = "#{scope}_#{short_uuid}"

      parsed_record_class, parsed_uuid = described_class.parse(ssuuid)

      expect(parsed_record_class).to eq(UserAccount)
      expect(parsed_uuid).to eq(uuid)
    end
  end

  describe '.find_record' do
    context 'when record is not found' do
      it 'returns nil' do
        ssuuid = "user_account_#{ShortUuid.from_uuid('00000000-0000-0000-0000-000000000000')}"

        user_account_found = described_class.find_record(ssuuid)

        expect(user_account_found).to be_nil
      end
    end

    context 'when record is found' do
      it 'returns the record' do
        user_account = create(:user_account)
        ssuuid = described_class.generate(user_account)

        user_account_found = described_class.find_record(ssuuid)

        expect(user_account_found).to eq(user_account)
      end
    end
  end

  describe '.record_exists?' do
    context 'when record is not found' do
      it 'returns false' do
        ssuuid = "user_account_#{ShortUuid.from_uuid('00000000-0000-0000-0000-000000000000')}"

        returned = described_class.record_exists?(ssuuid)

        expect(returned).to be(false)
      end
    end

    context 'when record is found' do
      it 'returns true' do
        user_account = create(:user_account)
        ssuuid = described_class.generate(user_account)

        returned = described_class.record_exists?(ssuuid)

        expect(returned).to be(true)
      end
    end
  end
end
