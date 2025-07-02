# frozen_string_literal: true

require "test_helper"

class PaginationTest < ActiveSupport::TestCase
  let(:described_class) { Pagination }

  describe "#page" do
    it "gets page from options, clamps value" do
      relation = Dummy.all
      [
        [20,   nil, nil,  20],
        ["20", nil, nil,  20],
        [20,   10,  nil,  10],
        [20,   nil, 25,   25],
        [20,   nil, "25", 25],
        [20,   10,  25,   10],

        [1,   nil, nil, 1],
        ["1", nil, nil, 1],
        [1,   nil, 5,   5],
        [1,   nil, "5", 5],
        [-1,   nil, nil, 1],
        ["-1", nil, nil, 1],
        [-1,   nil, 5,   5],
        [-1,   nil, "5", 5],

        [501, nil, nil,   200],
        [501, nil, 300,   200],
        [501, 300, nil,   300],
        [501, 300, 300,   300],
        [501, 300, "300", 300],

        [501, 1_000, nil,   500],
        [501, 1_000, 501,   500],
        [501, 1_000, 300,   300],
        [501, 1_000, "300", 300]
      ].each do |page, page_max, request_page_param, expected_page|
        request = build_request(params: { "page" => request_page_param })
        pagination = described_class.new(
          relation,
          request,
          page: page,
          page_max: page_max
        )

        assert_equal(expected_page, pagination.page)
      end
    end
  end

  describe "#per_page" do
    it "gets per_page from options, clamps value" do
      relation = Dummy.all
      [
        [20,   nil, false, nil, 20],
        ["20", nil, false, nil, 20],
        [20,   nil, false, 30,  20],
        [20,   10,  false, nil, 10],
        [20,   nil, true, nil,  20],
        [20,   nil, true, 25,   25],
        [20,   nil, true, "25", 25],
        [20,   10,  true, 25,   10],

        [1,   nil, false, nil, 1],
        ["1", nil, false, nil, 1],
        [1,   nil, false, 5,   1],
        [1,   nil, true,  nil, 1],
        [1,   nil, true,  5,   5],
        [-1,   nil, false, nil, 1],
        ["-1", nil, false, nil, 1],
        [-1,   nil, false, 5,   1],
        [-1,   nil, true,  nil, 1],
        [-1,   nil, true,  5,   5],
        [-1,   nil, true,  "5", 5],

        [501, nil, false, nil,   100],
        [501, nil, false, 300,   100],
        [501, 300, false, nil,   300],
        [501, 300, true,  nil,   300],
        [501, nil, true,  300,   100],
        [501, 300, true,  300,   300],
        [501, 300, true,  "300", 300],

        [501, 1_000, false, nil,   500],
        [501, 1_000, false, 300,   500],
        [501, 1_000, true,  nil,   500],
        [501, 1_000, true,  300,   300],
        [501, 1_000, true,  "300", 300]
      ].each do |per_page, per_page_max, per_page_from_request, request_per_page_param, expected_per_page|
        request = build_request(params: { "per_page" => request_per_page_param })
        pagination = described_class.new(
          relation,
          request,
          per_page: per_page,
          per_page_max: per_page_max,
          per_page_from_request: per_page_from_request
        )

        assert_equal(expected_per_page, pagination.per_page, "Failed for #{per_page.inspect} and #{expected_per_page.inspect}")
      end
    end
  end

  describe "#offset" do
    it "calculates offset according to per_page and page" do
      relation = Dummy.all
      request = build_request
      [
        [20, 1,  0],
        [20, 2, 20],
        [20, 3, 40],
        [20, 4, 60]
      ].each do |per_page, page, expected_offset|
        pagination = described_class.new(
          relation,
          request,
          per_page: per_page,
          page: page
        )

        assert_equal(expected_offset, pagination.offset)
      end
    end
  end

  describe "#results and #page_size" do
    describe "order asc" do
      it "takes per_page items from relation with offset for page" do
        dummies = 10.times.map { create_dummy }
        relation = Dummy.order(id: :asc)
        request = build_request

        pagination = described_class.new(relation, request, per_page: 3, page: 1)
        assert_equal([dummies[0], dummies[1], dummies[2]], pagination.results)
        assert_equal(3, pagination.page_size)

        pagination = described_class.new(relation, request, per_page: 3, page: 2)
        assert_equal([dummies[3], dummies[4], dummies[5]], pagination.results)
        assert_equal(3, pagination.page_size)

        pagination = described_class.new(relation, request, per_page: 3, page: 3)
        assert_equal([dummies[6], dummies[7], dummies[8]], pagination.results)
        assert_equal(3, pagination.page_size)

        pagination = described_class.new(relation, request, per_page: 3, page: 4)
        assert_equal([dummies[9]], pagination.results)
        assert_equal(1, pagination.page_size)

        pagination = described_class.new(relation, request, per_page: 3, page: 5)
        assert_empty(pagination.results)
        assert_equal(0, pagination.page_size)
      end
    end

    describe "order desc" do
      it "takes per_page items from relation with offset for page" do
        dummies = 10.times.map { create_dummy }
        relation = Dummy.order(id: :desc)
        request = build_request

        pagination = described_class.new(relation, request, per_page: 3, page: 1)
        assert_equal([dummies[9], dummies[8], dummies[7]], pagination.results)
        assert_equal(3, pagination.page_size)

        pagination = described_class.new(relation, request, per_page: 3, page: 2)
        assert_equal([dummies[6], dummies[5], dummies[4]], pagination.results)
        assert_equal(3, pagination.page_size)

        pagination = described_class.new(relation, request, per_page: 3, page: 3)
        assert_equal([dummies[3], dummies[2], dummies[1]], pagination.results)
        assert_equal(3, pagination.page_size)

        pagination = described_class.new(relation, request, per_page: 3, page: 4)
        assert_equal([dummies[0]], pagination.results)
        assert_equal(1, pagination.page_size)

        pagination = described_class.new(relation, request, per_page: 3, page: 5)
        assert_empty(pagination.results)
        assert_equal(0, pagination.page_size)
      end
    end
  end

  describe "#total_count, #total_pages, #last_page, #last_page?" do
    describe "when it is zero" do
      it "returns accordingly" do
        10.times { create_dummy }
        relation = Dummy.all
        request = build_request

        pagination = described_class.new(relation, request, total_count: 0, per_page: 3)

        assert_equal(0, pagination.total_count)
        assert_equal(1, pagination.total_pages)
        assert_equal(1, pagination.last_page)
        assert(pagination.last_page?)
      end
    end

    describe "when total_count option is given" do
      it "returns it" do
        10.times { create_dummy }
        relation = Dummy.all
        request = build_request

        pagination = described_class.new(relation, request, total_count: 100, per_page: 3)

        assert_equal(100, pagination.total_count)
        assert_equal(34, pagination.total_pages)
        assert_equal(34, pagination.last_page)
        assert_not(pagination.last_page?)

        pagination = described_class.new(relation, request, total_count: 100, per_page: 3, page: 34)

        assert_equal(100, pagination.total_count)
        assert_equal(34, pagination.total_pages)
        assert_equal(34, pagination.last_page)
        assert(pagination.last_page?)
      end
    end

    describe "when total_count option is not given" do
      it "returns relation count" do
        10.times { create_dummy }
        relation = Dummy.all
        request = build_request

        pagination = described_class.new(relation, request, total_count: nil, per_page: 3, page: 1)

        assert_equal(10, pagination.total_count)
        assert_equal(4, pagination.total_pages)
        assert_equal(4, pagination.last_page)
        assert_not(pagination.last_page?)

        pagination = described_class.new(relation, request, total_count: nil, per_page: 3, page: 4)

        assert_equal(10, pagination.total_count)
        assert_equal(4, pagination.total_pages)
        assert_equal(4, pagination.last_page)
        assert(pagination.last_page?)
      end
    end
  end

  describe "#first_page and #first_page?" do
    it "returns accordingly" do
      10.times { create_dummy }
      relation = Dummy.all
      request = build_request

      pagination = described_class.new(relation, request, per_page: 4, page: 1)
      assert_equal(1, pagination.first_page)
      assert(pagination.first_page?)

      pagination = described_class.new(relation, request, per_page: 4, page: 2)
      assert_equal(1, pagination.first_page)
      assert_not(pagination.first_page?)
    end
  end

  describe "#prev_page and #has_prev_page?" do
    it "returns accordingly" do
      [
        [-1, 1, false],
        [0, 1, false],
        [1, 1, false],
        [2, 1, true],
        [3, 2, true],
        [4, 3, true],
        [10, 9, true]
      ].each do |page, expected_prev_page, expected_has_prev_page|
        relation = Dummy.all
        request = build_request
        pagination = described_class.new(relation, request, page: page)

        assert_equal(expected_prev_page, pagination.prev_page)
        assert_equal(expected_has_prev_page, pagination.has_prev_page?)
      end
    end
  end

  describe "#next_page and #has_next_page?" do
    describe "when page_size is less than per_page" do
      it "returns page" do
        relation = Dummy.all
        request = build_request
        pagination = described_class.new(relation, request, per_page: 10, page: 1)

        assert_equal(1, pagination.next_page)
        assert_not(pagination.has_next_page?)
      end
    end

    describe "when relation_plus_one.size is less than per_page" do
      it "returns page" do
        4.times { create_dummy }
        relation = Dummy.all
        request = build_request
        pagination = described_class.new(relation, request, per_page: 5, page: 1)

        assert_equal(1, pagination.next_page)
        assert_not(pagination.has_next_page?)
      end
    end

    describe "when relation_plus_one.size is equal to per_page" do
      it "returns page" do
        5.times { create_dummy }
        relation = Dummy.all
        request = build_request
        pagination = described_class.new(relation, request, per_page: 5, page: 1)

        assert_equal(1, pagination.next_page)
        assert_not(pagination.has_next_page?)
      end
    end

    describe "when relation_plus_one.size is greater than per_page" do
      it "returns page + 1 or respects page_max" do
        6.times { create_dummy }
        relation = Dummy.all
        request = build_request

        pagination = described_class.new(relation, request, per_page: 5, page: 1)
        assert_equal(2, pagination.next_page)
        assert(pagination.has_next_page?)

        pagination = described_class.new(relation, request, per_page: 5, page: 1, page_max: 1)
        assert_equal(1, pagination.next_page)
        assert_not(pagination.has_next_page?)
      end
    end
  end

  describe "#first_page_url, #prev_page_url, #page_url, #next_page_url, #last_page_url" do
    it "returns accordingly" do
      10.times { create_dummy }
      relation = Dummy.all
      request = build_request(url: "http://uppertown.test/servers")

      pagination = described_class.new(relation, request, per_page: 4, page: 1)
      assert_equal("http://uppertown.test/servers?page=1", pagination.first_page_url)
      assert_equal("http://uppertown.test/servers?page=1", pagination.prev_page_url)
      assert_equal("http://uppertown.test/servers?page=1", pagination.page_url(1))
      assert_equal("http://uppertown.test/servers?page=2", pagination.next_page_url)
      assert_equal("http://uppertown.test/servers?page=3", pagination.last_page_url)

      pagination = described_class.new(relation, request, per_page: 4, page: 1, per_page_from_request: true)
      assert_equal("http://uppertown.test/servers?page=1&per_page=4", pagination.first_page_url)
      assert_equal("http://uppertown.test/servers?page=1&per_page=4", pagination.prev_page_url)
      assert_equal("http://uppertown.test/servers?page=1&per_page=4", pagination.page_url(1))
      assert_equal("http://uppertown.test/servers?page=2&per_page=4", pagination.next_page_url)
      assert_equal("http://uppertown.test/servers?page=3&per_page=4", pagination.last_page_url)

      pagination = described_class.new(relation, request, per_page: 4, page: 2)
      assert_equal("http://uppertown.test/servers?page=1", pagination.first_page_url)
      assert_equal("http://uppertown.test/servers?page=1", pagination.prev_page_url)
      assert_equal("http://uppertown.test/servers?page=2", pagination.page_url(2))
      assert_equal("http://uppertown.test/servers?page=3", pagination.next_page_url)
      assert_equal("http://uppertown.test/servers?page=3", pagination.last_page_url)

      pagination = described_class.new(relation, request, per_page: 4, page: 2, per_page_from_request: true)
      assert_equal("http://uppertown.test/servers?page=1&per_page=4", pagination.first_page_url)
      assert_equal("http://uppertown.test/servers?page=1&per_page=4", pagination.prev_page_url)
      assert_equal("http://uppertown.test/servers?page=2&per_page=4", pagination.page_url(2))
      assert_equal("http://uppertown.test/servers?page=3&per_page=4", pagination.next_page_url)
      assert_equal("http://uppertown.test/servers?page=3&per_page=4", pagination.last_page_url)

      pagination = described_class.new(relation, request, per_page: 4, page: 3)
      assert_equal("http://uppertown.test/servers?page=1", pagination.first_page_url)
      assert_equal("http://uppertown.test/servers?page=2", pagination.prev_page_url)
      assert_equal("http://uppertown.test/servers?page=3", pagination.page_url(3))
      assert_equal("http://uppertown.test/servers?page=3", pagination.next_page_url)
      assert_equal("http://uppertown.test/servers?page=3", pagination.last_page_url)

      pagination = described_class.new(relation, request, per_page: 4, page: 3, per_page_from_request: true)
      assert_equal("http://uppertown.test/servers?page=1&per_page=4", pagination.first_page_url)
      assert_equal("http://uppertown.test/servers?page=2&per_page=4", pagination.prev_page_url)
      assert_equal("http://uppertown.test/servers?page=3&per_page=4", pagination.page_url(3))
      assert_equal("http://uppertown.test/servers?page=3&per_page=4", pagination.next_page_url)
      assert_equal("http://uppertown.test/servers?page=3&per_page=4", pagination.last_page_url)
    end
  end
end
