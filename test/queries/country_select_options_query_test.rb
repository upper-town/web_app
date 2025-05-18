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

        expected_popular_options = build_country_code_options(["BR", "US", "AR"])
        expected_other_options = build_country_code_options(Server::COUNTRY_CODES - ["BR", "US", "AR"])

        query = described_class.new(cache_enabled: false)

        assert_equal(
          [
            expected_popular_options,
            expected_other_options
          ],
          query.call
        )
        assert_equal(expected_popular_options, query.popular_options)
        assert_equal(expected_other_options, query.other_options)
      end
    end

    describe "when only_in_use is true" do
      it "returns options with label and value only for countries with servers" do
        create_server(country_code: "US")
        create_server(country_code: "US")
        create_server(country_code: "BR")
        create_server(country_code: "BR")
        create_server(country_code: "AR")

        expected_popular_options = build_country_code_options(["BR", "US", "AR"])
        expected_other_options = build_country_code_options([])

        query = described_class.new(only_in_use: true, cache_enabled: false)

        assert_equal(
          [
            expected_popular_options,
            expected_other_options
          ],
          query.call
        )
        assert_equal(expected_popular_options, query.popular_options)
        assert_equal(expected_other_options, query.other_options)
      end

      it "returns a limit of popular countries" do
        create_server(country_code: "AR")
        create_server(country_code: "BE")
        create_server(country_code: "BR")
        create_server(country_code: "CA")
        create_server(country_code: "ES")
        create_server(country_code: "FR")
        create_server(country_code: "GB")
        create_server(country_code: "MX")
        create_server(country_code: "PT")
        create_server(country_code: "US")
        create_server(country_code: "UY")

        expected_popular_options = build_country_code_options(
          ["AR", "BE", "BR", "CA", "ES", "FR", "GB", "MX", "PT", "US"]
        )
        expected_other_options = build_country_code_options(["UY"])

        query = described_class.new(only_in_use: true)

        assert_equal(
          [
            expected_popular_options,
            expected_other_options
          ],
          query.call
        )
        assert_equal(expected_popular_options, query.popular_options)
        assert_equal(expected_other_options, query.other_options)
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
          assert_equal({ expires_in: 5.minutes }, options)
          assert_equal(
            [
              build_country_code_options(["BR", "US", "AR"]),
              build_country_code_options([])
            ],
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
          assert_equal({ expires_in: 5.minutes }, options)
          assert_equal(
            [
              build_country_code_options(["BR", "US", "AR"]),
              build_country_code_options(Server::COUNTRY_CODES - ["BR", "US", "AR"])
            ],
            block.call
          )
        end) do
          described_class.new(only_in_use: false, cache_enabled: true).call
        end
        assert_equal(1, called)
      end
    end
  end

  def build_country_code_options(country_codes)
    country_codes.map do |country_code|
      country = ISO3166::Country.new(country_code)

      ["#{country.emoji_flag} #{country.common_name}", country_code]
    end
  end
end
