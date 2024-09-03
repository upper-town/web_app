# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestHelper do
  describe '#url_with_query_params' do
    it 'returns url with query params merged/removed accordingly' do
      [
        ['https://example.com',      {}, [], 'https://example.com/'],
        ['https://example.com:5000', {}, [], 'https://example.com:5000/'],
        ['http://example.com',       {}, [], 'http://example.com/'],
        ['http://example.com:5000',  {}, [], 'http://example.com:5000/'],

        [
          'http://example.com:5000?aaa=111&bbb=test',
          { ccc: '333', 'ddd' => 444 },
          [],
          'http://example.com:5000/?aaa=111&bbb=test&ccc=333&ddd=444'
        ],
        [
          'http://example.com:5000?aaa=111&bbb=test',
          {},
          [:aaa, 'bbb'],
          'http://example.com:5000/'
        ],
        [
          'http://example.com:5000?aaa=111&bbb=test',
          { ccc: '333', 'ddd' => 444 },
          [:aaa, 'bbb'],
          'http://example.com:5000/?ccc=333&ddd=444'
        ],
      ].each do |original_url, params_merge, params_remove, updated_url|
        request = TestRequestHelper.build(url: original_url)

        expect(described_class.new(request).url_with_query_params(params_merge, params_remove))
          .to eq(updated_url)
      end
    end
  end

  describe '#app_host_referer?' do
    context 'when request.referer is blank' do
      it 'returns false' do
        request = TestRequestHelper.build(referer: ' ')

        expect(described_class.new(request).app_host_referer?).to be(false)
      end
    end

    context 'when request.referer is present' do
      context 'when scheme is not http/https' do
        it 'returns false' do
          request = TestRequestHelper.build(referer: 'ftp://example.com')

          expect(described_class.new(request).app_host_referer?).to be(false)
        end
      end

      context 'when scheme is http/https but host does not match APP_HOST' do
        it 'returns false' do
          [
            'https://example.com',
            'http://example.com',
          ].each do |referer|
            request = TestRequestHelper.build(referer: referer)

            expect(described_class.new(request).app_host_referer?).to be(false), "Failed for #{referer.inspect}"
          end
        end
      end

      context 'when scheme is http/https and host matches APP_HOST' do
        it 'returns true' do
          [
            'https://test.upper.town',
            'http://test.upper.town/',
            'http://test.upper.town:5000',
          ].each do |referer|
            request = TestRequestHelper.build(referer: referer)

            expect(described_class.new(request).app_host_referer?).to be(true), "Failed for #{referer.inspect}"
          end
        end
      end
    end
  end
end
