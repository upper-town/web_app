# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerWebhooks::CheckUpConfigJob do
  describe '#perform' do
    context 'when ServerWebhookConfig cannot be found with server_webhook_config_id' do
      it 'does not do anything' do
        described_class.new.perform(0)
        # TODO: ...
      end
    end

    context 'when ServerWebhookConfig is found with server_webhook_config_id' do
      context 'when ServerWebhookConfig is already disabled' do
        it 'does not do anything' do
          # TODO: ...
        end
      end

      context 'when few recent events are in retry or failed status with that config' do
        it 'does not do anything' do
          # TODO: ...
        end
      end

      context 'when many events are in retry or failed status with that config' do
        it 'disables the config, sets notice, and sends a notification about it' do
          # TODO: ...
        end
      end
    end
  end
end
