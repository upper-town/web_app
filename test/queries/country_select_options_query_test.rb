# frozen_string_literal: true

require "test_helper"

class CountrySelectOptionsQueryTest < ActiveSupport::TestCase
  let(:described_class) { CountrySelectOptionsQuery }

  describe "#call, #popular_options, #other_options" do
    describe "when only_in_use is false" do
      it "returns options with label and value for all server countries" do
        create_server(country_code: "US")
        create_server(country_code: "US")
        create_server(country_code: "BR")
        create_server(country_code: "BR")
        create_server(country_code: "AR")

        query = described_class.new(cache_enabled: false)

        assert_equal(
          build_country_code_options(Server::COUNTRY_CODES),
          query.call
        )
      end

      describe "with_continents: true" do
        it "returns options with label and value for all server countries and its continents" do
          create_server(country_code: "US")
          create_server(country_code: "US")
          create_server(country_code: "BR")
          create_server(country_code: "BR")
          create_server(country_code: "AR")

          query = described_class.new(with_continents: true, cache_enabled: false)

          assert_equal(
            build_continents_and_country_code_options(Server::COUNTRY_CODES),
            query.call
          )
        end
      end
    end

    describe "when only_in_use is true" do
      it "returns options with label and value only for countries with servers" do
        create_server(country_code: "US")
        create_server(country_code: "US")
        create_server(country_code: "BR")
        create_server(country_code: "BR")
        create_server(country_code: "AR")

        query = described_class.new(only_in_use: true, cache_enabled: false)

        assert_equal(
          build_country_code_options(["BR", "US", "AR"]),
          query.call
        )
      end

      describe "with_continents: true" do
        it "returns options with label and value only for server countries and its continents" do
          create_server(country_code: "US")
          create_server(country_code: "US")
          create_server(country_code: "BR")
          create_server(country_code: "BR")
          create_server(country_code: "AR")

          query = described_class.new(only_in_use: true, with_continents: true, cache_enabled: false)

          assert_equal(
            build_continents_and_country_code_options(["US", "BR", "AR"]),
            query.call
          )
        end
      end
    end

    describe "with cache_enabled" do
      it "caches result" do
        create_server(country_code: "US")
        create_server(country_code: "US")
        create_server(country_code: "BR")
        create_server(country_code: "BR")
        create_server(country_code: "AR")

        called = 0
        Rails.cache.stub(:fetch, ->(key, options, &block) do
          called += 1
          assert_equal("country_select_options_query:only_in_use", key)
          assert_equal({ expires_in: 1.minute }, options)
          assert_equal(
            build_country_code_options(["BR", "US", "AR"]),
            block.call
          )
        end) do
          described_class.new(only_in_use: true,  cache_enabled: true).call
        end
        assert_equal(1, called)

        called = 0
        Rails.cache.stub(:fetch, ->(key, options, &block) do
          called += 1
          assert_equal("country_select_options_query", key)
          assert_equal({ expires_in: 1.minute }, options)
          assert_equal(
            build_country_code_options(Server::COUNTRY_CODES),
            block.call
          )
        end) do
          described_class.new(only_in_use: false, cache_enabled: true).call
        end
        assert_equal(1, called)
      end
    end
  end

  def build_continents_and_country_code_options(country_codes)
    options = []

    country_codes
      .map { ISO3166::Country.new(it) }
      .sort_by { [it.continent, it.common_name] }
      .group_by { it.continent }
      .each do |continent, countries|
        options << [continent, countries.map { it.alpha2 }.join(","), { class: "fw-bold" }]
        options.concat(build_country_code_options(countries.map(&:alpha2)))
      end

    options
  end

  def build_country_code_options(country_codes)
    country_codes
      .map { ISO3166::Country.new(it) }
      .sort_by { it.common_name }
      .map do |country|
        ["#{country.emoji_flag} #{country.common_name}", country.alpha2]
      end
  end
end
