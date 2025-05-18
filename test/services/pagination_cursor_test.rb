# frozen_string_literal: true

require "test_helper"

class PaginationCursorTest < ActiveSupport::TestCase
  let(:described_class) { PaginationCursor }

  describe "#order" do
    it "gets order from options" do
      relation = Dummy.all
      [
        [" ",    nil,    "desc"],
        [" ",    " ",    "desc"],
        [" ",    "xxxx", "desc"],
        ["desc", nil,    "desc"],
        ["asc",  nil,    "asc"],
        ["desc", " ",    "desc"],
        ["asc",  " ",    "asc"],
        ["desc", "xxxx", "desc"],
        ["asc",  "xxxx", "desc"],
        ["xxxx", "asc",  "asc"],
        ["xxxx", "desc", "desc"],
        ["desc", "asc",  "asc"],
        ["asc",  "desc", "desc"]
      ].each do |order, request_order_param, expected_order|
        request = build_request(params: { "order" => request_order_param })
        pagination_cursor = described_class.new(
          relation,
          request,
          order: order
        )

        assert_equal(expected_order, pagination_cursor.order)
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
        pagination_cursor = described_class.new(
          relation,
          request,
          per_page: per_page,
          per_page_max: per_page_max,
          per_page_from_request: per_page_from_request
        )

        assert_equal(expected_per_page, pagination_cursor.per_page)
      end
    end
  end

  describe "#indicator" do
    it "gets indicator from options" do
      relation = Dummy.all
      [
        [" ",      nil,      "after"],
        ["before", nil,      "before"],
        ["before", " ",      "before"],
        ["after",  nil,      "after"],
        ["after",  " ",      "after"],
        ["after",  "xxx",    "after"],
        ["before", "xxx",    "after"],
        ["after",  "before", "before"],
        ["before", "after",  "after"]
      ].each do |indicator, request_indicator_param, expected_indicator|
        request = build_request(params: { "indicator" => request_indicator_param })
        pagination_cursor = described_class.new(
          relation,
          request,
          indicator: indicator
        )

        assert_equal(expected_indicator, pagination_cursor.indicator)
      end
    end
  end

  describe "#cursor and #cursor_id" do
    it "gets cursor and loads cursor_id" do
      _dummy1 = create_dummy(id: 1, uuid: SecureRandom.uuid, date: "2024-09-01", datetime: "2024-09-01T12:00:00.000001Z", decimal: "0.000001".to_d, float: 0.000001)
      _dummy2 = create_dummy(id: 2, uuid: SecureRandom.uuid, date: "2024-09-02", datetime: "2024-09-01T12:00:00.000002Z", decimal: "0.000002".to_d, float: 0.000002)
      dummy4  = create_dummy(id: 4, uuid: SecureRandom.uuid, date: "2024-09-04", datetime: "2024-09-01T12:00:00.000004Z", decimal: "0.000004".to_d, float: 0.000004)
      _dummy5 = create_dummy(id: 5, uuid: SecureRandom.uuid, date: "2024-09-05", datetime: "2024-09-01T12:00:00.000005Z", decimal: "0.000005".to_d, float: 0.000005)
      relation  = Dummy.all
      [
        # integer
        [:id, :integer, "desc", "after",  " ", nil, nil, nil],
        [:id, :integer, "desc", "before", " ", nil, nil, nil],
        [:id, :integer, "asc",  "after",  " ", nil, nil, nil],
        [:id, :integer, "asc",  "before", " ", nil, nil, nil],

        [:id, :integer, "desc", "after",  "abcdef", nil, nil, nil],
        [:id, :integer, "desc", "before", "abcdef", nil, nil, nil],
        [:id, :integer, "asc",  "after",  "abcdef", nil, nil, nil],
        [:id, :integer, "asc",  "before", "abcdef", nil, nil, nil],

        [:id, :integer, "desc", "after",  "3", nil, 2, 2],
        [:id, :integer, "desc", "before", "3", nil, 4, 4],
        [:id, :integer, "asc",  "after",  "3", nil, 4, 4],
        [:id, :integer, "asc",  "before", "3", nil, 2, 2],

        [:id, :integer, "desc", "after",  " ", " ",            nil, nil],
        [:id, :integer, "desc", "after",  "3", " ",            2,   2],
        [:id, :integer, "desc", "after",  " ", "abcdef",       nil, nil],
        [:id, :integer, "desc", "after",  " ", "3",            2,   2],
        [:id, :integer, "desc", "after",  " ", " 3!*[(?'\t\n", 2,   2],

        # string
        [:uuid, :string, "desc", "after",  " ", nil, nil, nil],
        [:uuid, :string, "desc", "before", " ", nil, nil, nil],
        [:uuid, :string, "asc",  "after",  " ", nil, nil, nil],
        [:uuid, :string, "asc",  "before", " ", nil, nil, nil],

        [:uuid, :string, "desc", "after",  "abcdef", nil, nil, nil],
        [:uuid, :string, "desc", "before", "abcdef", nil, nil, nil],
        [:uuid, :string, "asc",  "after",  "abcdef", nil, nil, nil],
        [:uuid, :string, "asc",  "before", "abcdef", nil, nil, nil],

        [:uuid, :string, "desc", "after",  " ",         " ",                         nil,         nil],
        [:uuid, :string, "desc", "after",  dummy4.uuid, " ",                         dummy4.uuid, 4],
        [:uuid, :string, "desc", "after",  " ",         "abcdef",                    nil,         nil],
        [:uuid, :string, "desc", "after",  " ",         dummy4.uuid,                 dummy4.uuid, 4],
        [:uuid, :string, "desc", "after",  " ",         " #{dummy4.uuid}!*[(?'\t\n", dummy4.uuid, 4],

        # date
        [:date, :date, "desc", "after",  " ", nil, nil, nil],
        [:date, :date, "desc", "before", " ", nil, nil, nil],
        [:date, :date, "asc",  "after",  " ", nil, nil, nil],
        [:date, :date, "asc",  "before", " ", nil, nil, nil],

        [:date, :date, "desc", "after",  "abcdef", nil, nil, nil],
        [:date, :date, "desc", "before", "abcdef", nil, nil, nil],
        [:date, :date, "asc",  "after",  "abcdef", nil, nil, nil],
        [:date, :date, "asc",  "before", "abcdef", nil, nil, nil],

        [:date, :date, "desc", "after",  "2024-09-03", nil, "2024-09-02".to_date, 2],
        [:date, :date, "desc", "before", "2024-09-03", nil, "2024-09-04".to_date, 4],
        [:date, :date, "asc",  "after",  "2024-09-03", nil, "2024-09-04".to_date, 4],
        [:date, :date, "asc",  "before", "2024-09-03", nil, "2024-09-02".to_date, 2],

        [:date, :date, "desc", "after",  " ",          " ",                     nil,                  nil],
        [:date, :date, "desc", "after",  "2024-09-03", " ",                     "2024-09-02".to_date, 2],
        [:date, :date, "desc", "after",  " ",          "abcdef",                nil,                  nil],
        [:date, :date, "desc", "after",  " ",          "2024-09-03",            "2024-09-02".to_date, 2],
        [:date, :date, "desc", "after",  " ",          " 2024-09-03!*[(?'\t\n", "2024-09-02".to_date, 2],

        # datetime
        [:datetime, :datetime, "desc", "after",  " ", nil, nil, nil],
        [:datetime, :datetime, "desc", "before", " ", nil, nil, nil],
        [:datetime, :datetime, "asc",  "after",  " ", nil, nil, nil],
        [:datetime, :datetime, "asc",  "before", " ", nil, nil, nil],

        [:datetime, :datetime, "desc", "after",  "abcdef", nil, nil, nil],
        [:datetime, :datetime, "desc", "before", "abcdef", nil, nil, nil],
        [:datetime, :datetime, "asc",  "after",  "abcdef", nil, nil, nil],
        [:datetime, :datetime, "asc",  "before", "abcdef", nil, nil, nil],

        [:datetime, :datetime, "desc", "after",  "2024-09-01T12:00:00.000003Z", nil, "2024-09-01T12:00:00.000002Z".to_time, 2],
        [:datetime, :datetime, "desc", "before", "2024-09-01T12:00:00.000003Z", nil, "2024-09-01T12:00:00.000004Z".to_time, 4],
        [:datetime, :datetime, "asc",  "after",  "2024-09-01T12:00:00.000003Z", nil, "2024-09-01T12:00:00.000004Z".to_time, 4],
        [:datetime, :datetime, "asc",  "before", "2024-09-01T12:00:00.000003Z", nil, "2024-09-01T12:00:00.000002Z".to_time, 2],

        [:datetime, :datetime, "desc", "after",  " ",                           " ",                                      nil,                                   nil],
        [:datetime, :datetime, "desc", "after",  "2024-09-01T12:00:00.000003Z", " ",                                      "2024-09-01T12:00:00.000002Z".to_time, 2],
        [:datetime, :datetime, "desc", "after",  " ",                           "abcdef",                                 nil,                                   nil],
        [:datetime, :datetime, "desc", "after",  " ",                           "2024-09-01T12:00:00.000003Z",            "2024-09-01T12:00:00.000002Z".to_time, 2],
        [:datetime, :datetime, "desc", "after",  " ",                           " 2024-09-01T12:00:00.000003Z!*[(?'\t\n", "2024-09-01T12:00:00.000002Z".to_time, 2],

        # decimal
        [:decimal, :decimal, "desc", "after",  " ", nil, nil, nil],
        [:decimal, :decimal, "desc", "before", " ", nil, nil, nil],
        [:decimal, :decimal, "asc",  "after",  " ", nil, nil, nil],
        [:decimal, :decimal, "asc",  "before", " ", nil, nil, nil],

        [:decimal, :decimal, "desc", "after",  "abcdef", nil, nil, nil],
        [:decimal, :decimal, "desc", "before", "abcdef", nil, nil, nil],
        [:decimal, :decimal, "asc",  "after",  "abcdef", nil, nil, nil],
        [:decimal, :decimal, "asc",  "before", "abcdef", nil, nil, nil],

        [:decimal, :decimal, "desc", "after",  "0.000003", nil, 0.000002, 2],
        [:decimal, :decimal, "desc", "before", "0.000003", nil, 0.000004, 4],
        [:decimal, :decimal, "asc",  "after",  "0.000003", nil, 0.000004, 4],
        [:decimal, :decimal, "asc",  "before", "0.000003", nil, 0.000002, 2],

        [:decimal, :decimal, "desc", "after",  " ",        " ",                   nil,      nil],
        [:decimal, :decimal, "desc", "after",  "0.000003", " ",                   0.000002, 2],
        [:decimal, :decimal, "desc", "after",  " ",        "abcdef",              nil,      nil],
        [:decimal, :decimal, "desc", "after",  " ",        "0.000003",            0.000002, 2],
        [:decimal, :decimal, "desc", "after",  " ",        " 0.000003!*[(?'\t\n", 0.000002, 2],

        # float
        [:float, :float, "desc", "after",  " ", nil, nil, nil],
        [:float, :float, "desc", "before", " ", nil, nil, nil],
        [:float, :float, "asc",  "after",  " ", nil, nil, nil],
        [:float, :float, "asc",  "before", " ", nil, nil, nil],

        [:float, :float, "desc", "after",  "abcdef", nil, nil, nil],
        [:float, :float, "desc", "before", "abcdef", nil, nil, nil],
        [:float, :float, "asc",  "after",  "abcdef", nil, nil, nil],
        [:float, :float, "asc",  "before", "abcdef", nil, nil, nil],

        [:float, :float, "desc", "after",  "0.000003", nil, 0.000002, 2],
        [:float, :float, "desc", "before", "0.000003", nil, 0.000004, 4],
        [:float, :float, "asc",  "after",  "0.000003", nil, 0.000004, 4],
        [:float, :float, "asc",  "before", "0.000003", nil, 0.000002, 2],

        [:float, :float, "desc", "after",  " ",        " ",                   nil,      nil],
        [:float, :float, "desc", "after",  "0.000003", " ",                   0.000002, 2],
        [:float, :float, "desc", "after",  " ",        "abcdef",              nil,      nil],
        [:float, :float, "desc", "after",  " ",        "0.000003",            0.000002, 2],
        [:float, :float, "desc", "after",  " ",        " 0.000003!*[(?'\t\n", 0.000002, 2]
      ].each do |cursor_column, cursor_type, order, indicator, cursor, request_cursor_param, expected_cursor, expected_cursor_id|
        request = build_request(params: { "cursor" => request_cursor_param })
        pagination_cursor = described_class.new(
          relation,
          request,
          cursor_column: cursor_column,
          cursor_type: cursor_type,
          order: order,
          indicator: indicator,
          cursor: cursor
        )

        assert(expected_cursor == pagination_cursor.cursor)
        assert(expected_cursor_id == pagination_cursor.cursor_id)
      end
    end
  end

  describe "#results and #page_size" do
    describe "order asc" do
      it "takes per_page items from relation for page" do
        dummies = 10.times.map { create_dummy }
        relation = Dummy.order(id: :desc)
        request = build_request

        pagination_cursor = described_class.new(relation, request, indicator: "before", cursor: "", per_page: 3, order: "asc")
        assert_equal([dummies[0], dummies[1], dummies[2]], pagination_cursor.results)
        assert_equal(3, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "after", cursor: "", per_page: 3, order: "asc")
        assert_equal([dummies[0], dummies[1], dummies[2]], pagination_cursor.results)
        assert_equal(3, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "before", cursor: dummies[0].id, per_page: 3, order: "asc")
        assert_empty(pagination_cursor.results)
        assert_equal(0, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "after", cursor: dummies[9].id, per_page: 3, order: "asc")
        assert_empty(pagination_cursor.results)
        assert_equal(0, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "before", cursor: dummies[2].id, per_page: 3, order: "asc")
        assert_equal([dummies[0], dummies[1]], pagination_cursor.results)
        assert_equal(2, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "after", cursor: dummies[2].id, per_page: 3, order: "asc")
        assert_equal([dummies[3], dummies[4], dummies[5]], pagination_cursor.results)
        assert_equal(3, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "before", cursor: dummies[3].id, per_page: 3, order: "asc")
        assert_equal([dummies[0], dummies[1], dummies[2]], pagination_cursor.results)
        assert_equal(3, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "before", cursor: dummies[8].id, per_page: 3, order: "asc")
        assert_equal([dummies[5], dummies[6], dummies[7]], pagination_cursor.results)
        assert_equal(3, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "after", cursor: dummies[8].id, per_page: 3, order: "asc")
        assert_equal([dummies[9]], pagination_cursor.results)
        assert_equal(1, pagination_cursor.page_size)
      end
    end

    describe "order desc" do
      it "takes per_page items from relation for page" do
        dummies = 10.times.map { create_dummy }
        relation = Dummy.order(id: :asc)
        request = build_request

        pagination_cursor = described_class.new(relation, request, indicator: "before", cursor: "", per_page: 3, order: "desc")
        assert_equal([dummies[9], dummies[8], dummies[7]], pagination_cursor.results)
        assert_equal(3, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "after", cursor: "", per_page: 3, order: "desc")
        assert_equal([dummies[9], dummies[8], dummies[7]], pagination_cursor.results)
        assert_equal(3, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "after", cursor: dummies[0].id, per_page: 3, order: "desc")
        assert_empty(pagination_cursor.results)
        assert_equal(0, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "before", cursor: dummies[9].id, per_page: 3, order: "desc")
        assert_empty(pagination_cursor.results)
        assert_equal(0, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "before", cursor: dummies[2].id, per_page: 3, order: "desc")
        assert_equal([dummies[5], dummies[4], dummies[3]], pagination_cursor.results)
        assert_equal(3, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "after", cursor: dummies[2].id, per_page: 3, order: "desc")
        assert_equal([dummies[1], dummies[0]], pagination_cursor.results)
        assert_equal(2, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "before", cursor: dummies[6].id, per_page: 3, order: "desc")
        assert_equal([dummies[9], dummies[8], dummies[7]], pagination_cursor.results)
        assert_equal(3, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "before", cursor: dummies[8].id, per_page: 3, order: "desc")
        assert_equal([dummies[9]], pagination_cursor.results)
        assert_equal(1, pagination_cursor.page_size)

        pagination_cursor = described_class.new(relation, request, indicator: "after", cursor: dummies[8].id, per_page: 3, order: "desc")
        assert_equal([dummies[7], dummies[6], dummies[5]], pagination_cursor.results)
        assert_equal(3, pagination_cursor.page_size)
      end
    end
  end

  describe "#total_count and #total_pages" do
    describe "when it is zero" do
      it "returns accordingly" do
        10.times { create_dummy }
        relation = Dummy.all
        request = build_request

        pagination_cursor = described_class.new(relation, request, total_count: 0, per_page: 3)

        assert_equal(0, pagination_cursor.total_count)
        assert_equal(1, pagination_cursor.total_pages)
      end
    end

    describe "when total_count option is given" do
      it "returns it" do
        10.times { create_dummy }
        relation = Dummy.all
        request = build_request

        pagination_cursor = described_class.new(relation, request, total_count: 100, per_page: 3)

        assert_equal(100, pagination_cursor.total_count)
        assert_equal(34, pagination_cursor.total_pages)
      end
    end

    describe "when total_count option is not given" do
      it "returns relation count" do
        10.times { create_dummy }
        relation = Dummy.all
        request = build_request

        pagination_cursor = described_class.new(relation, request, total_count: nil, per_page: 3)

        assert_equal(10, pagination_cursor.total_count)
        assert_equal(4, pagination_cursor.total_pages)
      end
    end
  end

  describe "#start_cursor, #start_cursor?, #start_cursor_url, #before_cursor, #has_before_cursor?, #before_cursor_url, #after_cursor, #has_after_cursor?, #after_cursor_url" do
    describe "with 0 records" do
      it "returns accordingly" do
        relation = Dummy.all
        request = build_request(url: "http://test.upper.town/servers")

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "after")

        assert_nil(pagination_cursor.start_cursor)
        assert(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

        assert_nil(pagination_cursor.before_cursor)
        assert_not(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before", pagination_cursor.before_cursor_url)

        assert_nil(pagination_cursor.after_cursor)
        assert_not(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "after", per_page_from_request: true)

        assert_nil(pagination_cursor.start_cursor)
        assert(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&per_page=3", pagination_cursor.start_cursor_url)

        assert_nil(pagination_cursor.before_cursor)
        assert_not(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before&per_page=3", pagination_cursor.before_cursor_url)

        assert_nil(pagination_cursor.after_cursor)
        assert_not(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&per_page=3", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "before")

        assert_nil(pagination_cursor.start_cursor)
        assert(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

        assert_nil(pagination_cursor.before_cursor)
        assert_not(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before", pagination_cursor.before_cursor_url)

        assert_nil(pagination_cursor.after_cursor)
        assert_not(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "before", per_page_from_request: true)

        assert_nil(pagination_cursor.start_cursor)
        assert(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&per_page=3", pagination_cursor.start_cursor_url)

        assert_nil(pagination_cursor.before_cursor)
        assert_not(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before&per_page=3", pagination_cursor.before_cursor_url)

        assert_nil(pagination_cursor.after_cursor)
        assert_not(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&per_page=3", pagination_cursor.after_cursor_url)
      end
    end

    describe "with 1 record" do
      it "returns accordingly" do
        dummy = create_dummy
        relation = Dummy.all
        request = build_request(url: "http://test.upper.town/servers")

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "after")

        assert_nil(pagination_cursor.start_cursor)
        assert(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

        assert_nil(pagination_cursor.before_cursor)
        assert_not(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before", pagination_cursor.before_cursor_url)

        assert_nil(pagination_cursor.after_cursor)
        assert_not(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "after", per_page_from_request: true)

        assert_nil(pagination_cursor.start_cursor)
        assert(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&per_page=3", pagination_cursor.start_cursor_url)

        assert_nil(pagination_cursor.before_cursor)
        assert_not(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before&per_page=3", pagination_cursor.before_cursor_url)

        assert_nil(pagination_cursor.after_cursor)
        assert_not(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&per_page=3", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "before")

        assert_nil(pagination_cursor.start_cursor)
        assert(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

        assert_nil(pagination_cursor.before_cursor)
        assert_not(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before", pagination_cursor.before_cursor_url)

        assert_equal(dummy.id, pagination_cursor.after_cursor)
        assert(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummy.id}", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "before", per_page_from_request: true)

        assert_nil(pagination_cursor.start_cursor)
        assert(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&per_page=3", pagination_cursor.start_cursor_url)

        assert_nil(pagination_cursor.before_cursor)
        assert_not(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before&per_page=3", pagination_cursor.before_cursor_url)

        assert_equal(dummy.id, pagination_cursor.after_cursor)
        assert(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummy.id}&per_page=3", pagination_cursor.after_cursor_url)
      end
    end

    describe "with many records" do
      it "returns accordingly" do
        dummies = 10.times.map { create_dummy }
        relation = Dummy.order(id: :desc)
        request = build_request(url: "http://test.upper.town/servers")

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "after")

        assert_nil(pagination_cursor.start_cursor)
        assert(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

        assert_nil(pagination_cursor.before_cursor)
        assert_not(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before", pagination_cursor.before_cursor_url)

        assert_equal(dummies[2].id, pagination_cursor.after_cursor)
        assert(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[2].id}", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "after", per_page_from_request: true)

        assert_nil(pagination_cursor.start_cursor)
        assert(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&per_page=3", pagination_cursor.start_cursor_url)

        assert_nil(pagination_cursor.before_cursor)
        assert_not(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before&per_page=3", pagination_cursor.before_cursor_url)

        assert_equal(dummies[2].id, pagination_cursor.after_cursor)
        assert(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[2].id}&per_page=3", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "before")

        assert_nil(pagination_cursor.start_cursor)
        assert(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

        assert_nil(pagination_cursor.before_cursor)
        assert_not(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before", pagination_cursor.before_cursor_url)

        assert_equal(dummies[2].id, pagination_cursor.after_cursor)
        assert(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[2].id}", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "before", per_page_from_request: true)

        assert_nil(pagination_cursor.start_cursor)
        assert(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&per_page=3", pagination_cursor.start_cursor_url)

        assert_nil(pagination_cursor.before_cursor)
        assert_not(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before&per_page=3", pagination_cursor.before_cursor_url)

        assert_equal(dummies[2].id, pagination_cursor.after_cursor)
        assert(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[2].id}&per_page=3", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "after", cursor: dummies[2].id)

        assert_nil(pagination_cursor.start_cursor)
        assert_not(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

        assert_equal(dummies[3].id, pagination_cursor.before_cursor)
        assert(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[3].id}", pagination_cursor.before_cursor_url)

        assert_equal(dummies[5].id, pagination_cursor.after_cursor)
        assert(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[5].id}", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "after", cursor: dummies[2].id, per_page_from_request: true)

        assert_nil(pagination_cursor.start_cursor)
        assert_not(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&per_page=3", pagination_cursor.start_cursor_url)

        assert_equal(dummies[3].id, pagination_cursor.before_cursor)
        assert(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[3].id}&per_page=3", pagination_cursor.before_cursor_url)

        assert_equal(dummies[5].id, pagination_cursor.after_cursor)
        assert(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[5].id}&per_page=3", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "after", cursor: dummies[8].id)

        assert_nil(pagination_cursor.start_cursor)
        assert_not(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

        assert_equal(dummies[9].id, pagination_cursor.before_cursor)
        assert(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[9].id}", pagination_cursor.before_cursor_url)

        assert_nil(pagination_cursor.after_cursor)
        assert_not(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "after", cursor: dummies[8].id, per_page_from_request: true)

        assert_nil(pagination_cursor.start_cursor)
        assert_not(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&per_page=3", pagination_cursor.start_cursor_url)

        assert_equal(dummies[9].id, pagination_cursor.before_cursor)
        assert(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[9].id}&per_page=3", pagination_cursor.before_cursor_url)

        assert_nil(pagination_cursor.after_cursor)
        assert_not(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&per_page=3", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "before", cursor: dummies[9].id)

        assert_nil(pagination_cursor.start_cursor)
        assert_not(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

        assert_equal(dummies[6].id, pagination_cursor.before_cursor)
        assert(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[6].id}", pagination_cursor.before_cursor_url)

        assert_equal(dummies[8].id, pagination_cursor.after_cursor)
        assert(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[8].id}", pagination_cursor.after_cursor_url)

        pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 3, indicator: "before", cursor: dummies[9].id, per_page_from_request: true)

        assert_nil(pagination_cursor.start_cursor)
        assert_not(pagination_cursor.start_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&per_page=3", pagination_cursor.start_cursor_url)

        assert_equal(dummies[6].id, pagination_cursor.before_cursor)
        assert(pagination_cursor.has_before_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[6].id}&per_page=3", pagination_cursor.before_cursor_url)

        assert_equal(dummies[8].id, pagination_cursor.after_cursor)
        assert(pagination_cursor.has_after_cursor?)
        assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[8].id}&per_page=3", pagination_cursor.after_cursor_url)
      end

      describe "string, date, datetime, decimal, float column_type" do
        it "returns accordingly" do
          dummies = [
            create_dummy(uuid: SecureRandom.uuid, date: "2024-09-01", datetime: "2024-09-01T12:00:00.000001Z", decimal: "0.000001".to_d, float: 0.000001), # index 0
            create_dummy(uuid: SecureRandom.uuid, date: "2024-09-02", datetime: "2024-09-01T12:00:00.000002Z", decimal: "0.000002".to_d, float: 0.000002), # index 1
            create_dummy(uuid: SecureRandom.uuid, date: "2024-09-03", datetime: "2024-09-01T12:00:00.000003Z", decimal: "0.000003".to_d, float: 0.000003), # index 2
            create_dummy(uuid: SecureRandom.uuid, date: "2024-09-04", datetime: "2024-09-01T12:00:00.000004Z", decimal: "0.000004".to_d, float: 0.000004), # index 3
            create_dummy(uuid: SecureRandom.uuid, date: "2024-09-05", datetime: "2024-09-01T12:00:00.000005Z", decimal: "0.000005".to_d, float: 0.000005) # index 4
          ]
          relation = Dummy.order(id: :desc)
          request = build_request(url: "http://test.upper.town/servers")

          pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 2, indicator: "after", cursor: dummies[1].uuid, cursor_type: :string, cursor_column: :uuid)

          assert_nil(pagination_cursor.start_cursor)
          assert_not(pagination_cursor.start_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

          assert_equal(dummies[2].uuid, pagination_cursor.before_cursor)
          assert(pagination_cursor.has_before_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[2].uuid}", pagination_cursor.before_cursor_url)

          assert_equal(dummies[3].uuid, pagination_cursor.after_cursor)
          assert(pagination_cursor.has_after_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[3].uuid}", pagination_cursor.after_cursor_url)

          pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 2, indicator: "after", cursor: dummies[1].date, cursor_type: :date, cursor_column: :date)

          assert_nil(pagination_cursor.start_cursor)
          assert_not(pagination_cursor.start_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

          assert_equal(dummies[2].date, pagination_cursor.before_cursor)
          assert(pagination_cursor.has_before_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[2].date.iso8601}", pagination_cursor.before_cursor_url)

          assert_equal(dummies[3].date, pagination_cursor.after_cursor)
          assert(pagination_cursor.has_after_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[3].date.iso8601}", pagination_cursor.after_cursor_url)

          pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 2, indicator: "after", cursor: dummies[1].datetime, cursor_type: :datetime, cursor_column: :datetime)

          assert_nil(pagination_cursor.start_cursor)
          assert_not(pagination_cursor.start_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

          assert_equal(dummies[2].datetime, pagination_cursor.before_cursor)
          assert(pagination_cursor.has_before_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{ERB::Util.url_encode(dummies[2].datetime.iso8601(6))}", pagination_cursor.before_cursor_url)

          assert_equal(dummies[3].datetime, pagination_cursor.after_cursor)
          assert(pagination_cursor.has_after_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{ERB::Util.url_encode(dummies[3].datetime.iso8601(6))}", pagination_cursor.after_cursor_url)

          pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 2, indicator: "after", cursor: dummies[1].decimal, cursor_type: :decimal, cursor_column: :decimal)

          assert_nil(pagination_cursor.start_cursor)
          assert_not(pagination_cursor.start_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

          assert_equal(dummies[2].decimal, pagination_cursor.before_cursor)
          assert(pagination_cursor.has_before_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[2].decimal}", pagination_cursor.before_cursor_url)

          assert_equal(dummies[3].decimal, pagination_cursor.after_cursor)
          assert(pagination_cursor.has_after_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[3].decimal}", pagination_cursor.after_cursor_url)

          pagination_cursor = described_class.new(relation, request, order: "asc", per_page: 2, indicator: "after", cursor: dummies[1].float, cursor_type: :float, cursor_column: :float)

          assert_nil(pagination_cursor.start_cursor)
          assert_not(pagination_cursor.start_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc", pagination_cursor.start_cursor_url)

          assert_equal(dummies[2].float, pagination_cursor.before_cursor)
          assert(pagination_cursor.has_before_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[2].float}", pagination_cursor.before_cursor_url)

          assert_equal(dummies[3].float, pagination_cursor.after_cursor)
          assert(pagination_cursor.has_after_cursor?)
          assert_equal("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[3].float}", pagination_cursor.after_cursor_url)
        end
      end
    end
  end
end
