# frozen_string_literal: true

require "test_helper"

class RequestHelperTest < ActiveSupport::TestCase
  let(:described_class) { RequestHelper }

  describe "#url_with_query" do
    it "returns url with query updated accordingly" do
      [
        ["https://example.com",      {}, [], "https://example.com/"],
        ["https://example.com:3000", {}, [], "https://example.com:3000/"],
        ["http://example.com",       {}, [], "http://example.com/"],
        ["http://example.com:3000",  {}, [], "http://example.com:3000/"],

        [
          "http://example.com:3000?aaa=111&bbb=test",
          { ccc: "333", "ddd" => 444 },
          [],
          "http://example.com:3000/?aaa=111&bbb=test&ccc=333&ddd=444"
        ],
        [
          "http://example.com:3000/path?aaa=111&bbb=test",
          {},
          [:aaa, "bbb"],
          "http://example.com:3000/path"
        ],
        [
          "http://example.com:3000/path/?aaa=111&bbb=test",
          { ccc: "333", "ddd" => 444 },
          [:aaa, "bbb"],
          "http://example.com:3000/path/?ccc=333&ddd=444"
        ]
      ].each do |original_url, params_merge, params_remove, updated_url|
        request = build_request(url: original_url)

        assert_equal(updated_url, described_class.new(request).url_with_query(params_merge, params_remove))
      end
    end
  end

  describe "#parse_and_update_query_and_uri" do
    it "returns parsed_query and parsed_uri updated accordingly" do
      [
        ["https://example.com",      {}, [], {}, "https://example.com/"],
        ["https://example.com:3000", {}, [], {}, "https://example.com:3000/"],
        ["http://example.com",       {}, [], {}, "http://example.com/"],
        ["http://example.com:3000",  {}, [], {}, "http://example.com:3000/"],

        [
          "http://example.com:3000?aaa=111&bbb=test",
          { ccc: "333", "ddd" => 444 },
          [],
          { "aaa" => "111", "bbb" => "test", "ccc" => "333", "ddd" => 444 },
          "http://example.com:3000/?aaa=111&bbb=test&ccc=333&ddd=444"
        ],
        [
          "http://example.com:3000/path?aaa=111&bbb=test",
          {},
          [:aaa, "bbb"],
          {},
          "http://example.com:3000/path"
        ],
        [
          "http://example.com:3000/path/?aaa=111&bbb=test",
          { ccc: "333", "ddd" => 444 },
          [:aaa, "bbb"],
          { "ccc" => "333", "ddd" => 444 },
          "http://example.com:3000/path/?ccc=333&ddd=444"
        ]
      ].each do |original_url, params_merge, params_remove, expected_parsed_query, expected_parsed_uri_string|
        request = build_request(url: original_url)

        parsed_query, parsed_uri = described_class.new(request).parse_and_update_query_and_uri(params_merge, params_remove)

        assert_equal(expected_parsed_query, parsed_query)
        assert_equal(expected_parsed_uri_string, parsed_uri.to_s)
      end
    end
  end

  describe "#parse_query_and_uri" do
    it "returns parsed_query and parsed_uri" do
      request = build_request(url: "http://example.com:3000/path/?aaa=111&bbb=test&ccc=333&ddd=444")

      parsed_query, parsed_uri = described_class.new(request).parse_query_and_uri

      assert_equal({ "aaa" => "111", "bbb" => "test", "ccc" => "333", "ddd" => "444" }, parsed_query)
      assert_equal("http", parsed_uri.scheme)
      assert_equal("example.com", parsed_uri.host)
      assert_equal(3000, parsed_uri.port)
      assert_equal("/path/", parsed_uri.path)
      assert_equal("aaa=111&bbb=test&ccc=333&ddd=444", parsed_uri.query)
    end
  end

  describe "#hidden_fields_for_query" do
    it "returns HTML inputs of type hidden for query" do
      request = build_request(url: "http://example.com:3000/path/?aaa=111&bbb=test&ccc=333&ddd=444")

      hidden_fields = described_class.new(request).hidden_fields_for_query({ "bbb" => "222" }, ["ccc"])

      assert(hidden_fields.html_safe?)
      assert_includes(hidden_fields, '<input type="hidden" name="aaa" value="111" />')
      assert_includes(hidden_fields, '<input type="hidden" name="bbb" value="222" />')
      assert_includes(hidden_fields, '<input type="hidden" name="ddd" value="444" />')
    end
  end

  describe "#app_host_referer?" do
    describe "when request.referer is blank" do
      it "returns false" do
        request = build_request(referer: " ")

        assert_not(described_class.new(request).app_host_referer?)
      end
    end

    describe "when request.referer is present" do
      describe "when scheme is not http/https" do
        it "returns false" do
          request = build_request(referer: "ftp://example.com")

          assert_not(described_class.new(request).app_host_referer?)
        end
      end

      describe "when scheme is http/https but host does not match webapp_host" do
        it "returns false" do
          [
            "https://example.com",
            "http://example.com"
          ].each do |referer|
            request = build_request(referer:)

            assert_not(described_class.new(request).app_host_referer?, "Failed for #{referer.inspect}")
          end
        end
      end

      describe "when scheme is http/https and host matches webapp_host" do
        it "returns true" do
          [
            "https://uppertown.test",
            "http://uppertown.test/",
            "http://uppertown.test:3100"
          ].each do |referer|
            request = build_request(referer:)

            assert(described_class.new(request).app_host_referer?, "Failed for #{referer.inspect}")
          end
        end
      end
    end
  end
end
