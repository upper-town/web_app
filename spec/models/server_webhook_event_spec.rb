# frozen_string_literal: true

# == Schema Information
#
# Table name: server_webhook_events
#
#  id                       :bigint           not null, primary key
#  delivered_at             :datetime
#  failed_attempts          :integer          default(0), not null
#  last_published_at        :datetime
#  notice                   :string           default(""), not null
#  payload                  :jsonb            not null
#  status                   :string           not null
#  type                     :string           not null
#  uuid                     :uuid             not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  server_id                :bigint           not null
#  server_webhook_config_id :bigint
#
# Indexes
#
#  index_server_webhook_events_on_server_id                 (server_id)
#  index_server_webhook_events_on_server_webhook_config_id  (server_webhook_config_id)
#  index_server_webhook_events_on_type                      (type)
#  index_server_webhook_events_on_updated_at                (updated_at)
#  index_server_webhook_events_on_uuid                      (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#  fk_rails_...  (server_webhook_config_id => server_webhook_configs.id)
#
require 'rails_helper'

RSpec.describe ServerWebhookEvent do
  describe 'associations' do
    it 'belongs to server' do
      server_webhook_event = create(:server_webhook_event)

      expect(server_webhook_event.server).to be_present
    end

    it 'belongs to config optionally' do
      server_webhook_event = create(:server_webhook_event, config: nil)

      expect(server_webhook_event.config).to be_blank

      server_webhook_config = create(:server_webhook_config)
      server_webhook_event = create(:server_webhook_event, config: server_webhook_config)

      expect(server_webhook_event.config).to eq(server_webhook_config)
    end
  end

  describe 'validations' do
    it 'validates status' do
      server_webhook_event = build(:server_webhook_event, status: ' ')
      server_webhook_event.validate
      expect(server_webhook_event.errors.of_kind?(:status, :blank)).to be(true)

      server_webhook_event = build(:server_webhook_event, status: 'aaaaaaaa')
      server_webhook_event.validate
      expect(server_webhook_event.errors.of_kind?(:status, :inclusion)).to be(true)

      server_webhook_event = build(:server_webhook_event, status: 'pending')
      server_webhook_event.validate
      expect(server_webhook_event.errors.key?(:status)).to be(false)
    end
  end

  describe '#pending?' do
    context 'when status is pending' do
      it 'returns true' do
        server_webhook_event = build(:server_webhook_event, status: 'pending')

        expect(server_webhook_event.pending?).to be(true)
      end
    end

    context 'when status is not pending' do
      it 'returns false' do
        server_webhook_event = build(:server_webhook_event, status: 'failed')

        expect(server_webhook_event.pending?).to be(false)
      end
    end
  end

  describe '#retry?' do
    context 'when status is retry' do
      it 'returns true' do
        server_webhook_event = build(:server_webhook_event, status: 'retry')

        expect(server_webhook_event.retry?).to be(true)
      end
    end

    context 'when status is not retry' do
      it 'returns false' do
        server_webhook_event = build(:server_webhook_event, status: 'failed')

        expect(server_webhook_event.retry?).to be(false)
      end
    end
  end

  describe '#delivered?' do
    context 'when status is delivered' do
      it 'returns true' do
        server_webhook_event = build(:server_webhook_event, status: 'delivered')

        expect(server_webhook_event.delivered?).to be(true)
      end
    end

    context 'when status is not delivered' do
      it 'returns false' do
        server_webhook_event = build(:server_webhook_event, status: 'failed')

        expect(server_webhook_event.delivered?).to be(false)
      end
    end
  end

  describe '#failed?' do
    context 'when status is failed' do
      it 'returns true' do
        server_webhook_event = build(:server_webhook_event, status: 'failed')

        expect(server_webhook_event.failed?).to be(true)
      end
    end

    context 'when status is not failed' do
      it 'returns false' do
        server_webhook_event = build(:server_webhook_event, status: 'pending')

        expect(server_webhook_event.failed?).to be(false)
      end
    end
  end

  describe '#maxed_failed_attempts?' do
    context 'when failed_attempts is equal to the limit' do
      it 'returns true' do
        server_webhook_event = create(
          :server_webhook_event,
          failed_attempts: described_class::MAX_FAILED_ATTEMPTS
        )

        expect(server_webhook_event.maxed_failed_attempts?).to be(true)
      end
    end

    context 'when failed_attempts is greater than the limit' do
      it 'returns true' do
        server_webhook_event = create(
          :server_webhook_event,
          failed_attempts: 26
        )

        expect(server_webhook_event.maxed_failed_attempts?).to be(true)
      end
    end

    context 'when failed_attempts is less than the limit' do
      it 'returns false' do
        server_webhook_event = create(
          :server_webhook_event,
          failed_attempts: 24
        )

        expect(server_webhook_event.maxed_failed_attempts?).to be(false)
      end
    end
  end

  describe '#retry_in' do
    context 'when status is not retry' do
      it 'returns nil' do
        server_webhook_event = create(:server_webhook_event, status: 'pending')

        expect(server_webhook_event.retry_in).to be_nil
      end
    end

    context 'when status is retry' do
      it 'returns seconds based on failed_attempts' do
        server_webhook_event = create(
          :server_webhook_event,
          status: 'retry',
          failed_attempts: 12
        )
        allow(SecureRandom)
          .to receive(:rand)
          .and_return(5)

        expect(server_webhook_event.retry_in).to eq(20856)

        expect(SecureRandom)
          .to have_received(:rand)
          .with(10)
      end
    end
  end
end
