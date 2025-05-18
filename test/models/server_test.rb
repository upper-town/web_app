# frozen_string_literal: true

require "test_helper"

class ServerTest < ActiveSupport::TestCase
  let(:described_class) { Server }

  describe "associations" do
    it "belongs to game" do
      server = create_server

      assert(server.game.present?)
    end

    it "has one banner_image" do
      server = create_server
      server_banner_image = create_server_banner_image(server:)

      assert_equal(server_banner_image, server.banner_image)
    end

    it "has many votes" do
      server = create_server
      server_vote1 = create_server_vote(server:)
      server_vote2 = create_server_vote(server:)

      assert_equal(
        [server_vote1, server_vote2].sort,
        server.votes.sort
      )
      server.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { server_vote1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { server_vote2.reload }
    end

    it "has many stats" do
      server = create_server
      server_stat1 = create_server_stat(server:)
      server_stat2 = create_server_stat(server:)

      assert_equal(
        [server_stat1, server_stat2].sort,
        server.stats.sort
      )
      server.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { server_stat1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { server_stat2.reload }
    end

    it "has many server_accounts" do
      server = create_server
      server_account1 = create_server_account(server:)
      server_account2 = create_server_account(server:)

      assert_equal(
        [server_account1, server_account2].sort,
        server.server_accounts.sort
      )
      server.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { server_account1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { server_account2.reload }
    end

    it "has many accounts through server_accounts" do
      server = create_server
      server_account1 = create_server_account(server:)
      server_account2 = create_server_account(server:)

      assert_equal(
        [server_account1.account, server_account2.account].sort,
        server.accounts.sort
      )
    end

    it "has many verified_accounts through server_accounts" do
      server = create_server
      _server_account1 = create_server_account(server:, verified_at: nil)
      server_account2  = create_server_account(server:, verified_at: Time.current)

      assert_equal(
        [server_account2.account],
        server.verified_accounts
      )
    end

    it "has many webhook_configs" do
      server = create_server
      server_webhook_config1 = create_server_webhook_config(server:)
      server_webhook_config2 = create_server_webhook_config(server:)

      assert_equal(
        [server_webhook_config1, server_webhook_config2].sort,
        server.webhook_configs.sort
      )
      server.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { server_webhook_config1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { server_webhook_config2.reload }
    end

    it "has many webhook_events" do
      server = create_server
      server_webhook_event1 = create_server_webhook_event(server:)
      server_webhook_event2 = create_server_webhook_event(server:)

      assert_equal(
        [server_webhook_event1, server_webhook_event2].sort,
        server.webhook_events.sort
      )
      server.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { server_webhook_event1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { server_webhook_event2.reload }
    end
  end

  describe "normalizations" do
    it "normalizes name" do
      server = create_server(name: "\n\t Server  Name \n")

      assert_equal("Server Name", server.name)
    end

    it "normalizes description" do
      server = create_server(description: "\n\t Server  description \n")

      assert_equal("Server description", server.description)
    end

    it "normalizes info" do
      server = create_server(info: "\n\t Server  info  \n")

      assert_equal("Server  info", server.info)
    end
  end

  describe "validations" do
    it "validates name" do
      server = build_server(name: " ")
      server.validate
      assert(server.errors.of_kind?(:name, :blank))

      server = build_server(name: "a" * 2)
      server.validate
      assert(server.errors.of_kind?(:name, :too_short))

      server = build_server(name: "a" * 256)
      server.validate
      assert(server.errors.of_kind?(:name, :too_long))

      server = build_server(name: "a" * 255)
      server.validate
      assert_not(server.errors.key?(:name))
    end

    it "validates description" do
      server = build_server(description: " ")
      server.validate
      assert_not(server.errors.of_kind?(:description, :blank))

      server = build_server(description: "a" * 1_001)
      server.validate
      assert(server.errors.of_kind?(:description, :too_long))

      server = build_server(description: "a" * 1_000)
      server.validate
      assert_not(server.errors.key?(:description))
    end

    it "validates info" do
      server = build_server(info: " ")
      server.validate
      assert_not(server.errors.of_kind?(:info, :blank))

      server = build_server(info: "a" * 1_001)
      server.validate
      assert(server.errors.of_kind?(:info, :too_long))

      server = build_server(info: "a" * 1_000)
      server.validate
      assert_not(server.errors.key?(:info))
    end

    it "validates country_code" do
      server = build_server(country_code: " ")
      server.validate
      assert(server.errors.of_kind?(:country_code, :blank))

      server = build_server(country_code: "123456")
      server.validate
      assert(server.errors.of_kind?(:country_code, :inclusion))

      server = build_server(country_code: "US")
      server.validate
      assert_not(server.errors.key?(:country_code))
    end

    it "validates site_url" do
      server = build_server(site_url: " ")
      server.validate
      assert(server.errors.of_kind?(:site_url, :blank))

      server = build_server(site_url: "a" * 2)
      server.validate
      assert(server.errors.of_kind?(:site_url, :too_short))

      server = build_server(site_url: "a" * 256)
      server.validate
      assert(server.errors.of_kind?(:site_url, :too_long))

      server = build_server(site_url: "abc://game")
      server.validate
      assert(server.errors.of_kind?(:site_url, :format_is_not_valid))

      server = build_server(site_url: "https://server-1.game.company.com")
      server.validate
      assert_not(server.errors.key?(:site_url))
    end

    it "validates verified_server_with_same_name_exist" do
      game = create_game
      server = build_server(name: "Server Name", game: game)
      existing_verified_server = create_server(
        name: "Server Name",
        game: game,
        verified_at: Time.current
      )

      server.verified_at = nil
      server.validate
      assert_not(server.errors.of_kind?(:name, :verified_server_with_same_name_exist))

      server.verified_at = Time.current
      server.validate
      assert(server.errors.of_kind?(:name, :verified_server_with_same_name_exist))

      existing_verified_server.destroy!

      server.validate
      assert_not(server.errors.key?(:name))
    end
  end

  describe ".archived" do
    it "returns servers with archived_at not nil" do
      server1 = create_server(archived_at: Time.current)
      _server2 = create_server(archived_at: nil)

      assert_equal(
        [server1],
        described_class.archived
      )
    end
  end

  describe ".not_archived" do
    it "returns servers with archived_at nil" do
      _server1 = create_server(archived_at: Time.current)
      server2 = create_server(archived_at: nil)

      assert_equal(
        [server2],
        described_class.not_archived
      )
    end
  end

  describe ".marked_for_deletion" do
    it "returns servers with marked_for_deletion_at not nil" do
      server1 = create_server(marked_for_deletion_at: Time.current)
      _server2 = create_server(marked_for_deletion_at: nil)

      assert_equal(
        [server1],
        described_class.marked_for_deletion
      )
    end
  end

  describe ".not_marked_for_deletion" do
    it "returns servers with marked_for_deletion_at nil" do
      _server1 = create_server(marked_for_deletion_at: Time.current)
      server2 = create_server(marked_for_deletion_at: nil)

      assert_equal(
        [server2],
        described_class.not_marked_for_deletion
      )
    end
  end

  describe ".verified" do
    it "returns servers with verified_at not nil" do
      server1 = create_server(verified_at: Time.current)
      _server2 = create_server(verified_at: nil)

      assert_equal(
        [server1],
        described_class.verified
      )
    end
  end

  describe ".not_verified" do
    it "returns servers with verified_at nil" do
      _server1 = create_server(verified_at: Time.current)
      server2 = create_server(verified_at: nil)

      assert_equal(
        [server2],
        described_class.not_verified
      )
    end
  end

  describe "#archived?" do
    describe "when archived_at is present" do
      it "returns true" do
        server = create_server(archived_at: Time.current)

        assert(server.archived?)
      end
    end

    describe "when archived_at is not present" do
      it "returns false" do
        server = create_server(archived_at: nil)

        assert_not(server.archived?)
      end
    end
  end

  describe "#not_archived?" do
    describe "when archived_at is present" do
      it "returns false" do
        server = create_server(archived_at: Time.current)

        assert_not(server.not_archived?)
      end
    end

    describe "when archived_at is not present" do
      it "returns true" do
        server = create_server(archived_at: nil)

        assert(server.not_archived?)
      end
    end
  end

  describe "#marked_for_deletion?" do
    describe "when marked_for_deletion_at is present" do
      it "returns true" do
        server = create_server(marked_for_deletion_at: Time.current)

        assert(server.marked_for_deletion?)
      end
    end

    describe "when marked_for_deletion_at is not present" do
      it "returns false" do
        server = create_server(marked_for_deletion_at: nil)

        assert_not(server.marked_for_deletion?)
      end
    end
  end

  describe "#not_marked_for_deletion?" do
    describe "when marked_for_deletion_at is present" do
      it "returns false" do
        server = create_server(marked_for_deletion_at: Time.current)

        assert_not(server.not_marked_for_deletion?)
      end
    end

    describe "when marked_for_deletion_at is not present" do
      it "returns true" do
        server = create_server(marked_for_deletion_at: nil)

        assert(server.not_marked_for_deletion?)
      end
    end
  end

  describe "#verified?" do
    describe "when verified_at is present" do
      it "returns true" do
        server = create_server(verified_at: Time.current)

        assert(server.verified?)
      end
    end

    describe "when verified_at is not present" do
      it "returns false" do
        server = create_server(verified_at: nil)

        assert_not(server.verified?)
      end
    end
  end

  describe "#not_verified?" do
    describe "when verified_at is present" do
      it "returns false" do
        server = create_server(verified_at: Time.current)

        assert_not(server.not_verified?)
      end
    end

    describe "when verified_at is not present" do
      it "returns true" do
        server = create_server(verified_at: nil)

        assert(server.not_verified?)
      end
    end
  end

  describe "#webhook_config" do
    describe "when enabled server_webhook_config exists for event_type" do
      it "returns it" do
        server = create_server
        server_webhook_config = create_server_webhook_config(
          server: server,
          event_types: ["test.event"],
          disabled_at: nil
        )

        assert_equal(server_webhook_config, server.webhook_config("test.event"))
      end
    end

    describe "when enabled server_webhook_config does not exit for event_type" do
      it "returns nil" do
        another_server = create_server
        _another_server_webhook_config = create_server_webhook_config(
          server: another_server,
          event_types: ["test.event"],
          disabled_at: nil
        )
        server = create_server
        _server_webhook_config = create_server_webhook_config(
          server: server,
          event_types: ["test.event"],
          disabled_at: Time.current
        )

        assert_nil(server.webhook_config("test.event"))
      end
    end
  end

  describe "#webhook_config?" do
    describe "when enabled server_webhook_config exists for event_type" do
      it "returns true" do
        server = create_server
        _server_webhook_config = create_server_webhook_config(
          server: server,
          event_types: ["test.event"],
          disabled_at: nil
        )

        assert(server.webhook_config?("test.event"))
      end
    end

    describe "when enabled server_webhook_config does not exit for event_type" do
      it "returns false" do
        another_server = create_server
        _another_server_webhook_config = create_server_webhook_config(
          server: another_server,
          event_types: ["test.event"],
          disabled_at: nil
        )
        server = create_server
        _server_webhook_config = create_server_webhook_config(
          server: server,
          event_types: ["test.event"],
          disabled_at: Time.current
        )

        assert_not(server.webhook_config?("test.event"))
      end
    end
  end

  describe "#integrated?" do
    describe "when enabled server_webhook_config exists for server_vote.created" do
      it "returns true" do
        server = create_server
        _server_webhook_config = create_server_webhook_config(
          server: server,
          event_types: ["server_vote.created"],
          disabled_at: nil
        )

        assert(server.integrated?)
      end
    end

    describe "when enabled server_webhook_config does not exit for server_vote.created" do
      it "returns false" do
        another_server = create_server
        _another_server_webhook_config = create_server_webhook_config(
          server: another_server,
          event_types: ["server_vote.created"],
          disabled_at: nil
        )
        server = create_server
        _server_webhook_config = create_server_webhook_config(
          server: server,
          event_types: ["server_vote.created"],
          disabled_at: Time.current
        )

        assert_not(server.integrated?)
      end
    end
  end
end
