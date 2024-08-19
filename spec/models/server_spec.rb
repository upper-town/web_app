# frozen_string_literal: true

# == Schema Information
#
# Table name: servers
#
#  id                     :bigint           not null, primary key
#  archived_at            :datetime
#  country_code           :string           not null
#  description            :string           default(""), not null
#  info                   :text             default(""), not null
#  marked_for_deletion_at :datetime
#  name                   :string           not null
#  site_url               :string           not null
#  verified_at            :datetime
#  verified_notice        :text             default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  game_id                :bigint           not null
#
# Indexes
#
#  index_servers_on_archived_at             (archived_at)
#  index_servers_on_country_code            (country_code)
#  index_servers_on_game_id                 (game_id)
#  index_servers_on_marked_for_deletion_at  (marked_for_deletion_at)
#  index_servers_on_name                    (name)
#  index_servers_on_verified_at             (verified_at)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
require 'rails_helper'

RSpec.describe Server do
  describe 'associations' do
    it 'belongs to game' do
      server = create(:server)

      expect(server.game).to be_present
    end

    it 'has one banner_image' do
      server = create(:server)
      server_banner_image = create(:server_banner_image, server: server)

      expect(server.banner_image).to eq(server_banner_image)
    end

    it 'has many votes' do
      server = create(:server)
      server_vote1 = create(:server_vote, server: server)
      server_vote2 = create(:server_vote, server: server)

      expect(server.votes).to contain_exactly(server_vote1, server_vote2)
      server.destroy!
      expect { server_vote1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { server_vote2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many stats' do
      server = create(:server)
      server_stat1 = create(:server_stat, server: server)
      server_stat2 = create(:server_stat, server: server)

      expect(server.stats).to contain_exactly(server_stat1, server_stat2)
      server.destroy!
      expect { server_stat1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { server_stat2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many server_accounts' do
      server = create(:server)
      server_account1 = create(:server_account, server: server)
      server_account2 = create(:server_account, server: server)

      expect(server.server_accounts).to contain_exactly(server_account1, server_account2)
      server.destroy!
      expect { server_account1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { server_account2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many accounts through server_accounts' do
      server = create(:server)
      server_account1 = create(:server_account, server: server)
      server_account2 = create(:server_account, server: server)

      expect(server.accounts).to contain_exactly(server_account1.account, server_account2.account)
    end

    it 'has many verified_accounts through server_accounts' do
      server = create(:server)
      _server_account1 = create(:server_account, server: server, verified_at: nil)
      server_account2 = create(:server_account, server: server, verified_at: Time.current)

      expect(server.verified_accounts).to contain_exactly(server_account2.account)
    end

    it 'has many webhook_configs' do
      server = create(:server)
      server_webhook_config1 = create(:server_webhook_config, server: server)
      server_webhook_config2 = create(:server_webhook_config, server: server)

      expect(server.webhook_configs).to contain_exactly(server_webhook_config1, server_webhook_config2)
      server.destroy!
      expect { server_webhook_config1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { server_webhook_config2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many webhook_secrets' do
      server = create(:server)
      server_webhook_secret1 = create(:server_webhook_secret, server: server)
      server_webhook_secret2 = create(:server_webhook_secret, server: server)

      expect(server.webhook_secrets).to contain_exactly(server_webhook_secret1, server_webhook_secret2)
      server.destroy!
      expect { server_webhook_secret1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { server_webhook_secret2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many webhook_events' do
      server = create(:server)
      server_webhook_event1 = create(:server_webhook_event, server: server)
      server_webhook_event2 = create(:server_webhook_event, server: server)

      expect(server.webhook_events).to contain_exactly(server_webhook_event1, server_webhook_event2)
      server.destroy!
      expect { server_webhook_event1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { server_webhook_event2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'normalizations' do
    it 'normalizes name' do
      server = create(:server, name: "\n\t Server  Name \n")

      expect(server.name).to eq('Server Name')
    end

    it 'normalizes description' do
      server = create(:server, description: "\n\t Server  description \n")

      expect(server.description).to eq('Server description')
    end

    it 'normalizes info' do
      server = create(:server, info: "\n\t Server  info  \n")

      expect(server.info).to eq('Server  info')
    end
  end

  describe 'validations' do
    it 'validates name' do
      server = build(:server, name: ' ')
      server.validate
      expect(server.errors.of_kind?(:name, :blank)).to be(true)

      server = build(:server, name: 'a' * 2)
      server.validate
      expect(server.errors.of_kind?(:name, :too_short)).to be(true)

      server = build(:server, name: 'a' * 256)
      server.validate
      expect(server.errors.of_kind?(:name, :too_long)).to be(true)

      server = build(:server, name: 'a' * 255)
      server.validate
      expect(server.errors.key?(:name)).to be(false)
    end

    it 'validates description' do
      server = build(:server, description: ' ')
      server.validate
      expect(server.errors.of_kind?(:description, :blank)).to be(false)

      server = build(:server, description: 'a' * 1_001)
      server.validate
      expect(server.errors.of_kind?(:description, :too_long)).to be(true)

      server = build(:server, description: 'a' * 1_000)
      server.validate
      expect(server.errors.key?(:description)).to be(false)
    end

    it 'validates info' do
      server = build(:server, info: ' ')
      server.validate
      expect(server.errors.of_kind?(:info, :blank)).to be(false)

      server = build(:server, info: 'a' * 1_001)
      server.validate
      expect(server.errors.of_kind?(:info, :too_long)).to be(true)

      server = build(:server, info: 'a' * 1_000)
      server.validate
      expect(server.errors.key?(:info)).to be(false)
    end

    it 'validates country_code' do
      server = build(:server, country_code: ' ')
      server.validate
      expect(server.errors.of_kind?(:country_code, :blank)).to be(true)

      server = build(:server, country_code: '123456')
      server.validate
      expect(server.errors.of_kind?(:country_code, :inclusion)).to be(true)

      server = build(:server, country_code: 'US')
      server.validate
      expect(server.errors.key?(:country_code)).to be(false)
    end

    it 'validates site_url' do
      server = build(:server, site_url: ' ')
      server.validate
      expect(server.errors.of_kind?(:site_url, :blank)).to be(true)

      server = build(:server, site_url: 'a' * 2)
      server.validate
      expect(server.errors.of_kind?(:site_url, :too_short)).to be(true)

      server = build(:server, site_url: 'a' * 256)
      server.validate
      expect(server.errors.of_kind?(:site_url, :too_long)).to be(true)

      server = build(:server, site_url: 'abc://example')
      server.validate
      expect(server.errors.of_kind?(:site_url, :format_is_not_valid)).to be(true)

      server = build(:server, site_url: 'https://server-1.game.example.com')
      server.validate
      expect(server.errors.key?(:site_url)).to be(false)
    end

    it 'validates verified_server_with_same_name_exist' do
      game = create(:game)
      server = build(:server, name: 'Server Name', game: game)
      existing_verified_server = create(
        :server,
        name: 'Server Name',
        game: game,
        verified_at: Time.current
      )
      server.validate
      expect(server.errors.of_kind?(:name, :verified_server_with_same_name_exist)).to be(true)

      existing_verified_server.destroy!
      server.validate
      expect(server.errors.key?(:name)).to be(false)
    end
  end

  describe '.archived' do
    it 'returns servers with archived_at not nil' do
      server1 = create(:server, archived_at: Time.current)
      _server2 = create(:server, archived_at: nil)

      expect(described_class.archived).to contain_exactly(server1)
    end
  end

  describe '.not_archived' do
    it 'returns servers with archived_at nil' do
      _server1 = create(:server, archived_at: Time.current)
      server2 = create(:server, archived_at: nil)

      expect(described_class.not_archived).to contain_exactly(server2)
    end
  end

  describe '.marked_for_deletion' do
    it 'returns servers with marked_for_deletion_at not nil' do
      server1 = create(:server, marked_for_deletion_at: Time.current)
      _server2 = create(:server, marked_for_deletion_at: nil)

      expect(described_class.marked_for_deletion).to contain_exactly(server1)
    end
  end

  describe '.not_marked_for_deletion' do
    it 'returns servers with marked_for_deletion_at nil' do
      _server1 = create(:server, marked_for_deletion_at: Time.current)
      server2 = create(:server, marked_for_deletion_at: nil)

      expect(described_class.not_marked_for_deletion).to contain_exactly(server2)
    end
  end

  describe '.verified' do
    it 'returns servers with verified_at not nil' do
      server1 = create(:server, verified_at: Time.current)
      _server2 = create(:server, verified_at: nil)

      expect(described_class.verified).to contain_exactly(server1)
    end
  end

  describe '.not_verified' do
    it 'returns servers with verified_at nil' do
      _server1 = create(:server, verified_at: Time.current)
      server2 = create(:server, verified_at: nil)

      expect(described_class.not_verified).to contain_exactly(server2)
    end
  end

  describe '#archived?' do
    context 'when archived_at is present' do
      it 'returns true' do
        server = create(:server, archived_at: Time.current)

        expect(server.archived?).to be(true)
      end
    end

    context 'when archived_at is not present' do
      it 'returns false' do
        server = create(:server, archived_at: nil)

        expect(server.archived?).to be(false)
      end
    end
  end

  describe '#not_archived?' do
    context 'when archived_at is present' do
      it 'returns false' do
        server = create(:server, archived_at: Time.current)

        expect(server.not_archived?).to be(false)
      end
    end

    context 'when archived_at is not present' do
      it 'returns true' do
        server = create(:server, archived_at: nil)

        expect(server.not_archived?).to be(true)
      end
    end
  end

  describe '#marked_for_deletion?' do
    context 'when marked_for_deletion_at is present' do
      it 'returns true' do
        server = create(:server, marked_for_deletion_at: Time.current)

        expect(server.marked_for_deletion?).to be(true)
      end
    end

    context 'when marked_for_deletion_at is not present' do
      it 'returns false' do
        server = create(:server, marked_for_deletion_at: nil)

        expect(server.marked_for_deletion?).to be(false)
      end
    end
  end

  describe '#not_marked_for_deletion?' do
    context 'when marked_for_deletion_at is present' do
      it 'returns false' do
        server = create(:server, marked_for_deletion_at: Time.current)

        expect(server.not_marked_for_deletion?).to be(false)
      end
    end

    context 'when marked_for_deletion_at is not present' do
      it 'returns true' do
        server = create(:server, marked_for_deletion_at: nil)

        expect(server.not_marked_for_deletion?).to be(true)
      end
    end
  end

  describe '#verified?' do
    context 'when verified_at is present' do
      it 'returns true' do
        server = create(:server, verified_at: Time.current)

        expect(server.verified?).to be(true)
      end
    end

    context 'when verified_at is not present' do
      it 'returns false' do
        server = create(:server, verified_at: nil)

        expect(server.verified?).to be(false)
      end
    end
  end

  describe '#not_verified?' do
    context 'when verified_at is present' do
      it 'returns false' do
        server = create(:server, verified_at: Time.current)

        expect(server.not_verified?).to be(false)
      end
    end

    context 'when verified_at is not present' do
      it 'returns true' do
        server = create(:server, verified_at: nil)

        expect(server.not_verified?).to be(true)
      end
    end
  end

  describe '#webhook_config' do
    context 'when enabled server_webhook_config exists for event_type' do
      it 'returns it' do
        another_server = create(:server)
        _another_server_webhook_config = create(
          :server_webhook_config,
          server: another_server,
          event_type: 'test.event',
          disabled_at: nil
        )
        server = create(:server)
        server_webhook_config = create(
          :server_webhook_config,
          server: server,
          event_type: 'test.event',
          disabled_at: nil
        )

        expect(server.webhook_config('test.event')).to eq(server_webhook_config)
      end
    end

    context 'when enabled server_webhook_config does not exit for event_type' do
      it 'returns nil' do
        another_server = create(:server)
        _another_server_webhook_config = create(
          :server_webhook_config,
          server: another_server,
          event_type: 'test.event',
          disabled_at: nil
        )
        server = create(:server)
        _server_webhook_config = create(
          :server_webhook_config,
          server: server,
          event_type: 'test.event',
          disabled_at: Time.current
        )

        expect(server.webhook_config('test.event')).to be_nil
      end
    end
  end

  describe '#webhook_config?' do
    context 'when enabled server_webhook_config exists for event_type' do
      it 'returns true' do
        another_server = create(:server)
        _another_server_webhook_config = create(
          :server_webhook_config,
          server: another_server,
          event_type: 'test.event',
          disabled_at: nil
        )
        server = create(:server)
        _server_webhook_config = create(
          :server_webhook_config,
          server: server,
          event_type: 'test.event',
          disabled_at: nil
        )

        expect(server.webhook_config?('test.event')).to be(true)
      end
    end

    context 'when enabled server_webhook_config does not exit for event_type' do
      it 'returns false' do
        another_server = create(:server)
        _another_server_webhook_config = create(
          :server_webhook_config,
          server: another_server,
          event_type: 'test.event',
          disabled_at: nil
        )
        server = create(:server)
        _server_webhook_config = create(
          :server_webhook_config,
          server: server,
          event_type: 'test.event',
          disabled_at: Time.current
        )

        expect(server.webhook_config?('test.event')).to be(false)
      end
    end
  end

  describe '#integrated?' do
    context 'when enabled server_webhook_config exists for server_votes.create' do
      it 'returns true' do
        another_server = create(:server)
        _another_server_webhook_config = create(
          :server_webhook_config,
          server: another_server,
          event_type: 'server_votes.create',
          disabled_at: nil
        )
        server = create(:server)
        _server_webhook_config = create(
          :server_webhook_config,
          server: server,
          event_type: 'server_votes.create',
          disabled_at: nil
        )

        expect(server.integrated?).to be(true)
      end
    end

    context 'when enabled server_webhook_config does not exit for server_votes.create' do
      it 'returns false' do
        another_server = create(:server)
        _another_server_webhook_config = create(
          :server_webhook_config,
          server: another_server,
          event_type: 'server_votes.create',
          disabled_at: nil
        )
        server = create(:server)
        _server_webhook_config = create(
          :server_webhook_config,
          server: server,
          event_type: 'server_votes.create',
          disabled_at: Time.current
        )

        expect(server.integrated?).to be(false)
      end
    end
  end
end
