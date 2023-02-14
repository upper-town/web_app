# frozen_string_literal: true

module Servers
  class IndexResultComponent < ApplicationComponent
    def initialize(server:, server_stats_hash:, period:, country_code:)
      @server = server
      @server_stats_hash = server_stats_hash
      @period = period
      @country_code = country_code

      @server_country_code_emoji_flag = ISO3166::Country.new(@server.country_code).emoji_flag
      @ranking_country_code_emoji_flag =
        if @country_code == 'global'
          ServerStat::GLOBAL_EMOJI_FLAG
        else
          ISO3166::Country.new(@country_code).emoji_flag
        end
    end

    def render?
      @server.present?
    end

    def format_ranking_number(value)
      number = format_number(value)
      '#' + (number.nil? ? '--' : number)
    end

    def format_vote_count(value)
      number = format_number(value)
      number.nil? ? '--' : number
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
          units: { thousand: 'k', million: 'M', billion: 'G', trillion: 'T' }
        )
      end
    end
  end
end
