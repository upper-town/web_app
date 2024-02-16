# frozen_string_literal: true

module Servers
  class IndexResultComponent < ApplicationComponent
    def initialize(server:, server_stats_hash:, period:, country_code:)
      super()

      @server = server
      @server_stats_hash = server_stats_hash
      @period = period
      @country_code = country_code

      @server_country_code_common_name, @server_country_code_emoji_flag =
        common_name_and_emoji_flag(@server.country_code)

      @ranking_country_code_common_name, @ranking_country_code_emoji_flag =
        common_name_and_emoji_flag(@country_code)
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

    def common_name_and_emoji_flag(country_code)
      if country_code == ServerStat::ALL
        ['All', ServerStat::ALL_EMOJI_FLAG]
      else
        iso_country = ISO3166::Country.new(country_code)

        [iso_country.common_name, iso_country.emoji_flag]
      end
    end
  end
end
