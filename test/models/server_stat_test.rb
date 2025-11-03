# frozen_string_literal: true

require "test_helper"

class ServerStatTest < ActiveSupport::TestCase
  let(:described_class) { ServerStat }

  describe "associations" do
    it "belongs to server" do
      server_stat = create_server_stat

      assert(server_stat.server.present?)
    end

    it "belongs to game" do
      server_stat = create_server_stat

      assert(server_stat.game.present?)
    end
  end

  describe "validations" do
    it "validates period" do
      server_stat = build_server_stat(period: " ")
      server_stat.validate

      assert(server_stat.errors.of_kind?(:period, :blank))

      server_stat = build_server_stat(period: "something_else")
      server_stat.validate

      assert(server_stat.errors.of_kind?(:period, :inclusion))

      server_stat = build_server_stat(period: Periods::PERIODS.sample)
      server_stat.validate

      assert_not(server_stat.errors.key?(:period))
    end
  end
end
