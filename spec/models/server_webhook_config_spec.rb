# frozen_string_literal: true

# == Schema Information
#
# Table name: server_webhook_configs
#
#  id          :bigint           not null, primary key
#  disabled_at :datetime
#  event_types :string           default(["\"*\""]), not null, is an Array
#  method      :string           default("POST"), not null
#  notice      :string           default(""), not null
#  secret      :string           not null
#  url         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  server_id   :bigint           not null
#
# Indexes
#
#  index_server_webhook_configs_on_server_id  (server_id)
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#
require 'rails_helper'

RSpec.describe ServerWebhookConfig do
  describe 'associations' do
    it 'belongs to server' do
      server_webhook_config = create(:server_webhook_config)

      expect(server_webhook_config.server).to be_present
    end

    it 'has many events' do
      server_webhook_config = create(:server_webhook_config)

      server_webhook_event1 = create(:server_webhook_event, config: server_webhook_config)
      server_webhook_event2 = create(:server_webhook_event, config: server_webhook_config)
      _server_webhook_event3 = create(:server_webhook_event)

      expect(server_webhook_config.events).to contain_exactly(server_webhook_event1, server_webhook_event2)
    end
  end

  describe 'normalizations' do
    it 'normalizes event_types' do
      server_webhook_config = create(
        :server_webhook_config,
        event_types: ["\n\t server_ vote.* \n", 'Server.Updated,123', 123, nil, ' ']
      )

      expect(server_webhook_config.event_types).to eq(['server_vote.*', 'server.updated'])
    end

    it 'normalizes secret' do
      server_webhook_config = create(
        :server_webhook_config,
        secret: " aaaaaaaa \naaaaaaaa \t\n"
      )

      expect(server_webhook_config.secret).to eq('aaaaaaaaaaaaaaaa')
    end

    it 'normalizes method' do
      server_webhook_config = create(
        :server_webhook_config,
        method: " PO \nst \t\n"
      )

      expect(server_webhook_config.method).to eq('POST')
    end
  end

  describe 'validations' do
    it 'validates method' do
      server_webhook_config = build(:server_webhook_config, method: ' ')
      server_webhook_config.validate
      expect(server_webhook_config.errors.of_kind?(:method, :blank)).to be(true)

      server_webhook_config = build(:server_webhook_config, method: 'DELETE')
      server_webhook_config.validate
      expect(server_webhook_config.errors.of_kind?(:method, :inclusion)).to be(true)

      server_webhook_config = build(:server_webhook_config, method: 'POST')
      server_webhook_config.validate
      expect(server_webhook_config.errors.key?(:method)).to be(false)
    end
  end

  describe '.enabled' do
    it 'returns server_webhook_config with disabled_at nil' do
      _server_webhook_config1 = create(:server_webhook_config, disabled_at: Time.current)
      server_webhook_config2 = create(:server_webhook_config, disabled_at: nil)

      expect(described_class.enabled).to contain_exactly(server_webhook_config2)
    end
  end

  describe '.disabled' do
    it 'returns server_webhook_config with disabled_at present' do
      server_webhook_config1 = create(:server_webhook_config, disabled_at: Time.current)
      _server_webhook_config2 = create(:server_webhook_config, disabled_at: nil)

      expect(described_class.disabled).to contain_exactly(server_webhook_config1)
    end
  end

  describe '.for' do
    it 'returns enabled server_webhook_config for server and event_type' do
      server = create(:server)
      other_server = create(:server)
      server_webhook_config1 = create(
        :server_webhook_config,
        server: server,
        event_types: ['server_vote.created'],
        disabled_at: nil
      )
      _server_webhook_config2 = create(
        :server_webhook_config,
        server: other_server,
        event_types: ['server_vote.created'],
        disabled_at: nil
      )
      _server_webhook_config3 = create(
        :server_webhook_config,
        server: server,
        event_types: ['server_vote.created'],
        disabled_at: Time.current
      )
      _server_webhook_config4 = create(
        :server_webhook_config,
        server: server,
        event_types: ['test.event'],
        disabled_at: nil
      )
      server_webhook_config5 = create(
        :server_webhook_config,
        server: server,
        event_types: ['server_vote.*'],
        disabled_at: nil
      )

      expect(described_class.for(server, 'server_vote.created')).to contain_exactly(
        server_webhook_config1,
        server_webhook_config5
      )
    end
  end

  describe '#enabled?' do
    context 'when disabled_at is present' do
      it 'returns false' do
        server_webhook_config = create(:server_webhook_config, disabled_at: Time.current)

        expect(server_webhook_config.enabled?).to be(false)
      end
    end

    context 'when disabled_at is not present' do
      it 'returns true' do
        server_webhook_config = create(:server_webhook_config, disabled_at: nil)

        expect(server_webhook_config.enabled?).to be(true)
      end
    end
  end

  describe '#disabled?' do
    context 'when disabled_at is present' do
      it 'returns true' do
        server_webhook_config = create(:server_webhook_config, disabled_at: Time.current)

        expect(server_webhook_config.disabled?).to be(true)
      end
    end

    context 'when disabled_at is not present' do
      it 'returns false' do
        server_webhook_config = create(:server_webhook_config, disabled_at: nil)

        expect(server_webhook_config.disabled?).to be(false)
      end
    end
  end

  describe '#subscribed? and #not_subscribed?' do
    it 'glob matches event_types with given string' do
      [
        [true,  'server_vote.created', ['*']],
        [true,  'server_vote.created', ['server_vote.created']],
        [true,  'server_vote.created', ['server*']],
        [true,  'server_vote.created', ['server_vote.*']],
        [true,  'server_vote.created', ['*created']],
        [true,  'server_vote.created', ['aaaa', 'server_vote.*']],
        [false, 'server_vote.created', ['server_vote']],
      ].each do |should_match, str, event_types|
        server_webhook_config = build(:server_webhook_config, event_types: event_types)

        if should_match
          expect(server_webhook_config.subscribed?(str))
            .to be(true), "Failed for #{should_match.inspect} #{str.inspect} #{event_types.inspect}"
          expect(server_webhook_config.not_subscribed?(str))
            .to be(false)
        else
          expect(server_webhook_config.subscribed?(str))
            .to be(false), "Failed for #{should_match.inspect} #{str.inspect} #{event_types.inspect}"
          expect(server_webhook_config.not_subscribed?(str))
            .to be(true)
        end
      end
    end
  end
end
