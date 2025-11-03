# frozen_string_literal: true

module Servers
  class IndexResultComponent < ViewComponent::Base
    attr_reader :server, :server_stats_hash, :period

    def initialize(server:, server_stats_hash:, period:)
      super()

      @server = server
      @server_stats_hash = server_stats_hash
      @period = period
    end

    def render?
      @server.present?
    end

    def format_ranking_number(value)
      number = format_number(value)
      "#" + (number.nil? ? "--" : number)
    end

    def format_vote_count(value)
      number = format_number(value)
      number.nil? ? "--" : number
    end

    private

    def format_number(value)
      if value.nil? || value.negative?
        nil
      elsif value < 100_000
        number_with_delimiter(value)
      else
        number_to_human(
          value,
          precision: 4,
          units: { thousand: "k", million: "M", billion: "G", trillion: "T" }
        )
      end
    end
  end
end
