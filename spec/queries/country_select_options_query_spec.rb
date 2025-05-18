require 'rails_helper'

RSpec.describe CountrySelectOptionsQuery do
  describe '#call, #popular_options, #other_options' do
    context 'when only_in_use is false' do
      it 'returns options with label and value for all server countries' do
        create(:server, country_code: 'US')
        create(:server, country_code: 'US')
        create(:server, country_code: 'BR')
        create(:server, country_code: 'BR')
        create(:server, country_code: 'AR')

        expected_popular_options = build_country_code_options([ 'BR', 'US', 'AR' ])
        expected_other_options = build_country_code_options(Server::COUNTRY_CODES - [ 'BR', 'US', 'AR' ])

        query = described_class.new(cache_enabled: false)

        expect(query.call).to eq([
          expected_popular_options,
          expected_other_options
        ])
        expect(query.popular_options).to eq(expected_popular_options)
        expect(query.other_options).to eq(expected_other_options)
      end
    end

    context 'when only_in_use is true' do
      it 'returns options with label and value only for countries with servers' do
        create(:server, country_code: 'US')
        create(:server, country_code: 'US')
        create(:server, country_code: 'BR')
        create(:server, country_code: 'BR')
        create(:server, country_code: 'AR')

        expected_popular_options = build_country_code_options([ 'BR', 'US', 'AR' ])
        expected_other_options = build_country_code_options([])

        query = described_class.new(only_in_use: true, cache_enabled: false)

        expect(query.call).to eq([
          expected_popular_options,
          expected_other_options
        ])
        expect(query.popular_options).to eq(expected_popular_options)
        expect(query.other_options).to eq(expected_other_options)
      end

      it 'returns a limit of popular countries' do
        create(:server, country_code: 'AR')
        create(:server, country_code: 'BE')
        create(:server, country_code: 'BR')
        create(:server, country_code: 'CA')
        create(:server, country_code: 'ES')
        create(:server, country_code: 'FR')
        create(:server, country_code: 'GB')
        create(:server, country_code: 'MX')
        create(:server, country_code: 'PT')
        create(:server, country_code: 'US')
        create(:server, country_code: 'UY')

        expected_popular_options = build_country_code_options(
          [ 'AR', 'BE', 'BR', 'CA', 'ES', 'FR', 'GB', 'MX', 'PT', 'US' ]
        )
        expected_other_options = build_country_code_options([ 'UY' ])

        query = described_class.new(only_in_use: true)

        expect(query.call).to eq([
          expected_popular_options,
          expected_other_options
        ])
        expect(query.popular_options).to eq(expected_popular_options)
        expect(query.other_options).to eq(expected_other_options)
      end
    end

    describe 'with cache_enabled' do
      it 'caches result' do
        create(:server, country_code: 'US')
        create(:server, country_code: 'US')
        create(:server, country_code: 'BR')
        create(:server, country_code: 'BR')
        create(:server, country_code: 'AR')
        allow(Rails.cache)
          .to receive(:fetch)

        described_class.new(only_in_use: true, cache_enabled: true).call

        expect(Rails.cache)
          .to have_received(:fetch)
          .with('country_select_options_query:only_in_use', expires_in: 5.minutes) do |&block|
            expect(block.call).to eq([
              build_country_code_options([ 'BR', 'US', 'AR' ]),
              build_country_code_options([])
            ])
          end

        described_class.new(only_in_use: false, cache_enabled: true).call

        expect(Rails.cache)
          .to have_received(:fetch)
          .with('country_select_options_query', expires_in: 5.minutes) do |&block|
            expect(block.call).to eq([
              build_country_code_options([ 'BR', 'US', 'AR' ]),
              build_country_code_options(Server::COUNTRY_CODES - [ 'BR', 'US', 'AR' ])
            ])
          end
      end
    end
  end

  def build_country_code_options(country_codes)
    country_codes.map do |country_code|
      country = ISO3166::Country.new(country_code)

      [ "#{country.emoji_flag} #{country.common_name}", country_code ]
    end
  end
end
