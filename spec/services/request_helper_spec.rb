# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestHelper do
  describe '#url_with_query' do
    it 'returns url with query updated accordingly' do
      [
        ['https://example.com',      {}, [], 'https://example.com/'],
        ['https://example.com:3000', {}, [], 'https://example.com:3000/'],
        ['http://example.com',       {}, [], 'http://example.com/'],
        ['http://example.com:3000',  {}, [], 'http://example.com:3000/'],

        [
          'http://example.com:3000?aaa=111&bbb=test',
          { ccc: '333', 'ddd' => 444 },
          [],
          'http://example.com:3000/?aaa=111&bbb=test&ccc=333&ddd=444'
        ],
        [
          'http://example.com:3000/path?aaa=111&bbb=test',
          {},
          [:aaa, 'bbb'],
          'http://example.com:3000/path'
        ],
        [
          'http://example.com:3000/path/?aaa=111&bbb=test',
          { ccc: '333', 'ddd' => 444 },
          [:aaa, 'bbb'],
          'http://example.com:3000/path/?ccc=333&ddd=444'
        ],
      ].each do |original_url, params_merge, params_remove, updated_url|
        request = TestRequestHelper.build(url: original_url)

        expect(described_class.new(request).url_with_query(params_merge, params_remove))
          .to eq(updated_url)
      end
    end
  end

  describe '#parse_and_update_query_and_uri' do
    it 'returns parsed_query and parsed_uri updated accordingly' do
      [
        ['https://example.com',      {}, [], {}, 'https://example.com/'],
        ['https://example.com:3000', {}, [], {}, 'https://example.com:3000/'],
        ['http://example.com',       {}, [], {}, 'http://example.com/'],
        ['http://example.com:3000',  {}, [], {}, 'http://example.com:3000/'],

        [
          'http://example.com:3000?aaa=111&bbb=test',
          { ccc: '333', 'ddd' => 444 },
          [],
          { 'aaa' => '111', 'bbb' => 'test', 'ccc' => '333', 'ddd' => 444 },
          'http://example.com:3000/?aaa=111&bbb=test&ccc=333&ddd=444'
        ],
        [
          'http://example.com:3000/path?aaa=111&bbb=test',
          {},
          [:aaa, 'bbb'],
          {},
          'http://example.com:3000/path'
        ],
        [
          'http://example.com:3000/path/?aaa=111&bbb=test',
          { ccc: '333', 'ddd' => 444 },
          [:aaa, 'bbb'],
          { 'ccc' => '333', 'ddd' => 444 },
          'http://example.com:3000/path/?ccc=333&ddd=444'
        ],
      ].each do |original_url, params_merge, params_remove, expected_parsed_query, expected_parsed_uri_string|
        request = TestRequestHelper.build(url: original_url)

        parsed_query, parsed_uri = described_class.new(request).parse_and_update_query_and_uri(params_merge, params_remove)

        expect(parsed_query).to eq(expected_parsed_query)
        expect(parsed_uri.to_s).to eq(expected_parsed_uri_string)
      end
    end
  end

  describe '#parse_query_and_uri' do
    it 'returns parsed_query and parsed_uri' do
      request = TestRequestHelper.build(url: 'http://example.com:3000/path/?aaa=111&bbb=test&ccc=333&ddd=444')

      parsed_query, parsed_uri = described_class.new(request).parse_query_and_uri

      expect(parsed_query).to eq({ 'aaa' => '111', 'bbb' => 'test', 'ccc' => '333', 'ddd' => '444' })
      expect(parsed_uri.scheme).to eq('http')
      expect(parsed_uri.host).to eq('example.com')
      expect(parsed_uri.port).to eq(3000)
      expect(parsed_uri.path).to eq('/path/')
      expect(parsed_uri.query).to eq('aaa=111&bbb=test&ccc=333&ddd=444')
    end
  end

  describe '#hidden_fields_for_query' do
    it 'returns HTML inputs of type hidden for query' do
      request = TestRequestHelper.build(url: 'http://example.com:3000/path/?aaa=111&bbb=test&ccc=333&ddd=444')

      hidden_fields = described_class.new(request).hidden_fields_for_query({ 'bbb' => '222' }, ['ccc'])

      expect(hidden_fields.html_safe?).to be(true)
      expect(hidden_fields).to include('<input type="hidden" name="aaa" value="111" autocomplete="off" />')
      expect(hidden_fields).to include('<input type="hidden" name="bbb" value="222" autocomplete="off" />')
      expect(hidden_fields).to include('<input type="hidden" name="ddd" value="444" autocomplete="off" />')
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
            'http://test.upper.town:3000',
          ].each do |referer|
            request = TestRequestHelper.build(referer: referer)

            expect(described_class.new(request).app_host_referer?).to be(true), "Failed for #{referer.inspect}"
          end
        end
      end
    end
  end
end
