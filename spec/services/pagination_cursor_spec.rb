# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Rails/TimeZone
RSpec.describe PaginationCursor do
  describe '#order' do
    it 'gets order from options' do
      relation = Dummy.all
      [
        [' ',    false, nil, 'desc' ],
        ['desc', false, nil, 'desc' ],
        ['xxxx', false, nil, 'desc' ],
        ['asc',  false, nil, 'asc'  ],

        [' ',    true,  ' ',    'desc' ],
        [' ',    true,  'xxxx', 'desc' ],
        ['desc', true,  ' ',    'desc' ],
        ['desc', true,  'xxxx', 'desc' ],
        ['desc', true,  'asc',  'asc'  ],
        ['asc',  true,  ' ',    'asc'  ],
      ].each do |order, order_from_request, request_order_param, expected_order|
        request = TestRequestHelper.build(params: { 'order' => request_order_param })
        pagination_cursor = described_class.new(
          relation,
          request,
          order: order,
          order_from_request: order_from_request
        )

        expect(pagination_cursor.order).to eq(expected_order)
      end
    end
  end

  describe '#per_page' do
    it 'gets per_page from options, clamps value' do
      relation = Dummy.all
      [
        [20,   nil, false, nil, 20],
        ['20', nil, false, nil, 20],
        [20,   nil, false, 30,  20],
        [20,   10,  false, nil, 10],
        [20,   nil, true, nil,  20],
        [20,   nil, true, 25,   25],
        [20,   nil, true, '25', 25],
        [20,   10,  true, 25,   10],

        [ 1,   nil, false, nil, 1],
        [ '1', nil, false, nil, 1],
        [ 1,   nil, false, 5,   1],
        [ 1,   nil, true,  nil, 1],
        [ 1,   nil, true,  5,   5],
        [-1,   nil, false, nil, 1],
        ['-1', nil, false, nil, 1],
        [-1,   nil, false, 5,   1],
        [-1,   nil, true,  nil, 1],
        [-1,   nil, true,  5,   5],
        [-1,   nil, true,  '5', 5],

        [501, nil, false, nil,   100],
        [501, nil, false, 300,   100],
        [501, 300, false, nil,   300],
        [501, 300, true,  nil,   300],
        [501, nil, true,  300,   100],
        [501, 300, true,  300,   300],
        [501, 300, true,  '300', 300],

        [501, 1_000, false, nil,   500],
        [501, 1_000, false, 300,   500],
        [501, 1_000, true,  nil,   500],
        [501, 1_000, true,  300,   300],
        [501, 1_000, true,  '300', 300],
      ].each do |per_page, per_page_max, per_page_from_request, request_per_page_param, expected_per_page|
        request = TestRequestHelper.build(params: { 'per_page' => request_per_page_param })
        pagination_cursor = described_class.new(
          relation,
          request,
          per_page: per_page,
          per_page_max: per_page_max,
          per_page_from_request: per_page_from_request
        )

        expect(pagination_cursor.per_page).to eq(expected_per_page)
      end
    end
  end

  describe '#indicator' do
    it 'gets indicator from options' do
      relation = Dummy.all
      [
        [' ',      nil,      'after' ],
        ['before', nil,      'before'],
        ['before', ' ',      'before'],
        ['after',  nil,      'after' ],
        ['after',  ' ',      'after' ],
        ['after',  'xxx',    'after' ],
        ['before', 'xxx',    'after' ],
        ['after',  'before', 'before'],
        ['before', 'after',  'after' ],
      ].each do |indicator, request_indicator_param, expected_indicator|
        request = TestRequestHelper.build(params: { 'indicator' => request_indicator_param })
        pagination_cursor = described_class.new(
          relation,
          request,
          indicator: indicator
        )

        expect(pagination_cursor.indicator).to eq(expected_indicator)
      end
    end
  end

  describe '#cursor and #cursor_id' do
    it 'gets cursor and loads cursor_id' do
      _dummy1 = create(:dummy, id: 1, uuid: SecureRandom.uuid, date: '2024-09-01', datetime: '2024-09-01T12:00:00.000001Z', decimal: '0.000001'.to_d, float: 0.000001)
      _dummy2 = create(:dummy, id: 2, uuid: SecureRandom.uuid, date: '2024-09-02', datetime: '2024-09-01T12:00:00.000002Z', decimal: '0.000002'.to_d, float: 0.000002)
      dummy4  = create(:dummy, id: 4, uuid: SecureRandom.uuid, date: '2024-09-04', datetime: '2024-09-01T12:00:00.000004Z', decimal: '0.000004'.to_d, float: 0.000004)
      _dummy5 = create(:dummy, id: 5, uuid: SecureRandom.uuid, date: '2024-09-05', datetime: '2024-09-01T12:00:00.000005Z', decimal: '0.000005'.to_d, float: 0.000005)
      relation  = Dummy.all
      [
        # integer
        [:id, :integer, 'desc', 'after',  ' ', nil, nil, nil],
        [:id, :integer, 'desc', 'before', ' ', nil, nil, nil],
        [:id, :integer, 'asc',  'after',  ' ', nil, nil, nil],
        [:id, :integer, 'asc',  'before', ' ', nil, nil, nil],

        [:id, :integer, 'desc', 'after',  'abcdef', nil, nil, nil],
        [:id, :integer, 'desc', 'before', 'abcdef', nil, nil, nil],
        [:id, :integer, 'asc',  'after',  'abcdef', nil, nil, nil],
        [:id, :integer, 'asc',  'before', 'abcdef', nil, nil, nil],

        [:id, :integer, 'desc', 'after',  '3', nil, 2, 2],
        [:id, :integer, 'desc', 'before', '3', nil, 4, 4],
        [:id, :integer, 'asc',  'after',  '3', nil, 4, 4],
        [:id, :integer, 'asc',  'before', '3', nil, 2, 2],

        [:id, :integer, 'desc', 'after',  ' ', ' ',            nil, nil],
        [:id, :integer, 'desc', 'after',  '3', ' ',            2,   2  ],
        [:id, :integer, 'desc', 'after',  ' ', 'abcdef',       nil, nil],
        [:id, :integer, 'desc', 'after',  ' ', '3',            2,   2  ],
        [:id, :integer, 'desc', 'after',  ' ', " 3!*[(?'\t\n", 2,   2  ],

        # string
        [:uuid, :string, 'desc', 'after',  ' ', nil, nil, nil],
        [:uuid, :string, 'desc', 'before', ' ', nil, nil, nil],
        [:uuid, :string, 'asc',  'after',  ' ', nil, nil, nil],
        [:uuid, :string, 'asc',  'before', ' ', nil, nil, nil],

        [:uuid, :string, 'desc', 'after',  'abcdef', nil, nil, nil],
        [:uuid, :string, 'desc', 'before', 'abcdef', nil, nil, nil],
        [:uuid, :string, 'asc',  'after',  'abcdef', nil, nil, nil],
        [:uuid, :string, 'asc',  'before', 'abcdef', nil, nil, nil],

        [:uuid, :string, 'desc', 'after',  ' ',         ' ',                         nil,         nil],
        [:uuid, :string, 'desc', 'after',  dummy4.uuid, ' ',                         dummy4.uuid, 4  ],
        [:uuid, :string, 'desc', 'after',  ' ',         'abcdef',                    nil,         nil],
        [:uuid, :string, 'desc', 'after',  ' ',         dummy4.uuid,                 dummy4.uuid, 4  ],
        [:uuid, :string, 'desc', 'after',  ' ',         " #{dummy4.uuid}!*[(?'\t\n", dummy4.uuid, 4  ],

        # date
        [:date, :date, 'desc', 'after',  ' ', nil, nil, nil],
        [:date, :date, 'desc', 'before', ' ', nil, nil, nil],
        [:date, :date, 'asc',  'after',  ' ', nil, nil, nil],
        [:date, :date, 'asc',  'before', ' ', nil, nil, nil],

        [:date, :date, 'desc', 'after',  'abcdef', nil, nil, nil],
        [:date, :date, 'desc', 'before', 'abcdef', nil, nil, nil],
        [:date, :date, 'asc',  'after',  'abcdef', nil, nil, nil],
        [:date, :date, 'asc',  'before', 'abcdef', nil, nil, nil],

        [:date, :date, 'desc', 'after',  '2024-09-03', nil, '2024-09-02'.to_date, 2],
        [:date, :date, 'desc', 'before', '2024-09-03', nil, '2024-09-04'.to_date, 4],
        [:date, :date, 'asc',  'after',  '2024-09-03', nil, '2024-09-04'.to_date, 4],
        [:date, :date, 'asc',  'before', '2024-09-03', nil, '2024-09-02'.to_date, 2],

        [:date, :date, 'desc', 'after',  ' ',          ' ',                     nil,                  nil],
        [:date, :date, 'desc', 'after',  '2024-09-03', ' ',                     '2024-09-02'.to_date, 2  ],
        [:date, :date, 'desc', 'after',  ' ',          'abcdef',                nil,                  nil],
        [:date, :date, 'desc', 'after',  ' ',          '2024-09-03',            '2024-09-02'.to_date, 2  ],
        [:date, :date, 'desc', 'after',  ' ',          " 2024-09-03!*[(?'\t\n", '2024-09-02'.to_date, 2  ],

        # datetime
        [:datetime, :datetime, 'desc', 'after',  ' ', nil, nil, nil],
        [:datetime, :datetime, 'desc', 'before', ' ', nil, nil, nil],
        [:datetime, :datetime, 'asc',  'after',  ' ', nil, nil, nil],
        [:datetime, :datetime, 'asc',  'before', ' ', nil, nil, nil],

        [:datetime, :datetime, 'desc', 'after',  'abcdef', nil, nil, nil],
        [:datetime, :datetime, 'desc', 'before', 'abcdef', nil, nil, nil],
        [:datetime, :datetime, 'asc',  'after',  'abcdef', nil, nil, nil],
        [:datetime, :datetime, 'asc',  'before', 'abcdef', nil, nil, nil],

        [:datetime, :datetime, 'desc', 'after',  '2024-09-01T12:00:00.000003Z', nil, '2024-09-01T12:00:00.000002Z'.to_time, 2],
        [:datetime, :datetime, 'desc', 'before', '2024-09-01T12:00:00.000003Z', nil, '2024-09-01T12:00:00.000004Z'.to_time, 4],
        [:datetime, :datetime, 'asc',  'after',  '2024-09-01T12:00:00.000003Z', nil, '2024-09-01T12:00:00.000004Z'.to_time, 4],
        [:datetime, :datetime, 'asc',  'before', '2024-09-01T12:00:00.000003Z', nil, '2024-09-01T12:00:00.000002Z'.to_time, 2],

        [:datetime, :datetime, 'desc', 'after',  ' ',                           ' ',                                      nil,                                   nil],
        [:datetime, :datetime, 'desc', 'after',  '2024-09-01T12:00:00.000003Z', ' ',                                      '2024-09-01T12:00:00.000002Z'.to_time, 2  ],
        [:datetime, :datetime, 'desc', 'after',  ' ',                           'abcdef',                                 nil,                                   nil],
        [:datetime, :datetime, 'desc', 'after',  ' ',                           '2024-09-01T12:00:00.000003Z',            '2024-09-01T12:00:00.000002Z'.to_time, 2  ],
        [:datetime, :datetime, 'desc', 'after',  ' ',                           " 2024-09-01T12:00:00.000003Z!*[(?'\t\n", '2024-09-01T12:00:00.000002Z'.to_time, 2  ],

        # decimal
        [:decimal, :decimal, 'desc', 'after',  ' ', nil, nil, nil],
        [:decimal, :decimal, 'desc', 'before', ' ', nil, nil, nil],
        [:decimal, :decimal, 'asc',  'after',  ' ', nil, nil, nil],
        [:decimal, :decimal, 'asc',  'before', ' ', nil, nil, nil],

        [:decimal, :decimal, 'desc', 'after',  'abcdef', nil, nil, nil],
        [:decimal, :decimal, 'desc', 'before', 'abcdef', nil, nil, nil],
        [:decimal, :decimal, 'asc',  'after',  'abcdef', nil, nil, nil],
        [:decimal, :decimal, 'asc',  'before', 'abcdef', nil, nil, nil],

        [:decimal, :decimal, 'desc', 'after',  '0.000003', nil, 0.000002, 2],
        [:decimal, :decimal, 'desc', 'before', '0.000003', nil, 0.000004, 4],
        [:decimal, :decimal, 'asc',  'after',  '0.000003', nil, 0.000004, 4],
        [:decimal, :decimal, 'asc',  'before', '0.000003', nil, 0.000002, 2],

        [:decimal, :decimal, 'desc', 'after',  ' ',        ' ',                   nil,      nil],
        [:decimal, :decimal, 'desc', 'after',  '0.000003', ' ',                   0.000002, 2  ],
        [:decimal, :decimal, 'desc', 'after',  ' ',        'abcdef',              nil,      nil],
        [:decimal, :decimal, 'desc', 'after',  ' ',        '0.000003',            0.000002, 2  ],
        [:decimal, :decimal, 'desc', 'after',  ' ',        " 0.000003!*[(?'\t\n", 0.000002, 2  ],

        # float
        [:float, :float, 'desc', 'after',  ' ', nil, nil, nil],
        [:float, :float, 'desc', 'before', ' ', nil, nil, nil],
        [:float, :float, 'asc',  'after',  ' ', nil, nil, nil],
        [:float, :float, 'asc',  'before', ' ', nil, nil, nil],

        [:float, :float, 'desc', 'after',  'abcdef', nil, nil, nil],
        [:float, :float, 'desc', 'before', 'abcdef', nil, nil, nil],
        [:float, :float, 'asc',  'after',  'abcdef', nil, nil, nil],
        [:float, :float, 'asc',  'before', 'abcdef', nil, nil, nil],

        [:float, :float, 'desc', 'after',  '0.000003', nil, 0.000002, 2],
        [:float, :float, 'desc', 'before', '0.000003', nil, 0.000004, 4],
        [:float, :float, 'asc',  'after',  '0.000003', nil, 0.000004, 4],
        [:float, :float, 'asc',  'before', '0.000003', nil, 0.000002, 2],

        [:float, :float, 'desc', 'after',  ' ',        ' ',                   nil,      nil],
        [:float, :float, 'desc', 'after',  '0.000003', ' ',                   0.000002, 2  ],
        [:float, :float, 'desc', 'after',  ' ',        'abcdef',              nil,      nil],
        [:float, :float, 'desc', 'after',  ' ',        '0.000003',            0.000002, 2  ],
        [:float, :float, 'desc', 'after',  ' ',        " 0.000003!*[(?'\t\n", 0.000002, 2  ],
      ].each do |cursor_column, cursor_type, order, indicator, cursor, request_cursor_param, expected_cursor, expected_cursor_id|
        request = TestRequestHelper.build(params: { 'cursor' => request_cursor_param })
        pagination_cursor = described_class.new(
          relation,
          request,
          cursor_column: cursor_column,
          cursor_type: cursor_type,
          order: order,
          indicator: indicator,
          cursor: cursor
        )

        expect(pagination_cursor.cursor).to eq(expected_cursor)
        expect(pagination_cursor.cursor_id).to eq(expected_cursor_id)
      end
    end
  end

  describe '#results and #page_size' do
    describe 'order asc' do
      it 'takes per_page items from relation for page' do
        dummies = create_list(:dummy, 10)
        relation = Dummy.order(id: :desc)
        request = TestRequestHelper.build

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: '', per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([dummies[0], dummies[1], dummies[2]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: '', per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([dummies[0], dummies[1], dummies[2]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: dummies[0].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to be_empty
        expect(pagination_cursor.page_size).to eq(0)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: dummies[9].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to be_empty
        expect(pagination_cursor.page_size).to eq(0)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: dummies[2].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([dummies[0], dummies[1]])
        expect(pagination_cursor.page_size).to eq(2)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: dummies[2].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([dummies[3], dummies[4], dummies[5]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: dummies[3].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([dummies[0], dummies[1], dummies[2]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: dummies[8].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([dummies[5], dummies[6], dummies[7]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: dummies[8].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([dummies[9]])
        expect(pagination_cursor.page_size).to eq(1)
      end
    end

    describe 'order desc' do
      it 'takes per_page items from relation for page' do
        dummies = create_list(:dummy, 10)
        relation = Dummy.order(id: :asc)
        request = TestRequestHelper.build

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: '', per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to eq([dummies[9], dummies[8], dummies[7]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: '', per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to eq([dummies[9], dummies[8], dummies[7]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: dummies[0].id, per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to be_empty
        expect(pagination_cursor.page_size).to eq(0)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: dummies[9].id, per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to be_empty
        expect(pagination_cursor.page_size).to eq(0)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: dummies[2].id, per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to eq([dummies[5], dummies[4], dummies[3]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: dummies[2].id, per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to eq([dummies[1], dummies[0]])
        expect(pagination_cursor.page_size).to eq(2)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: dummies[6].id, per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to eq([dummies[9], dummies[8], dummies[7]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: dummies[8].id, per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to eq([dummies[9]])
        expect(pagination_cursor.page_size).to eq(1)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: dummies[8].id, per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to eq([dummies[7], dummies[6], dummies[5]])
        expect(pagination_cursor.page_size).to eq(3)
      end
    end
  end

  describe '#total_count and #total_pages' do
    context 'when it is zero' do
      it 'returns accordingly' do
        create_list(:dummy, 10)
        relation = Dummy.all
        request = TestRequestHelper.build

        pagination_cursor = described_class.new(relation, request, total_count: 0, per_page: 3)

        expect(pagination_cursor.total_count).to eq(0)
        expect(pagination_cursor.total_pages).to eq(1)
      end
    end

    context 'when total_count option is given' do
      it 'returns it' do
        create_list(:dummy, 10)
        relation = Dummy.all
        request = TestRequestHelper.build

        pagination_cursor = described_class.new(relation, request, total_count: 100, per_page: 3)

        expect(pagination_cursor.total_count).to eq(100)
        expect(pagination_cursor.total_pages).to eq(34)
      end
    end

    context 'when total_count option is not given' do
      it 'returns relation count' do
        create_list(:dummy, 10)
        relation = Dummy.all
        request = TestRequestHelper.build

        pagination_cursor = described_class.new(relation, request, total_count: nil, per_page: 3)

        expect(pagination_cursor.total_count).to eq(10)
        expect(pagination_cursor.total_pages).to eq(4)
      end
    end
  end

  describe '#start_cursor, #start_cursor?, #start_cursor_url, #before_cursor, #has_before_cursor?, #before_cursor_url, #after_cursor, #has_after_cursor?, #after_cursor_url' do
    describe 'with 0 records' do
      it 'returns accordingly' do
        relation = Dummy.all
        request = TestRequestHelper.build(url: 'http://test.upper.town/servers')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before&per_page=3')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after&per_page=3')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before&per_page=3')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after&per_page=3')
      end
    end

    describe 'with 1 record' do
      it 'returns accordingly' do
        dummy = create(:dummy)
        relation = Dummy.all
        request = TestRequestHelper.build(url: 'http://test.upper.town/servers')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before&per_page=3')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after&per_page=3')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before')

        expect(pagination_cursor.after_cursor).to eq(dummy.id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummy.id}")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before&per_page=3')

        expect(pagination_cursor.after_cursor).to eq(dummy.id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummy.id}&per_page=3")
      end
    end

    describe 'with many records' do
      it 'returns accordingly' do
        dummies = create_list(:dummy, 10)
        relation = Dummy.order(id: :desc)
        request = TestRequestHelper.build(url: 'http://test.upper.town/servers')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before')

        expect(pagination_cursor.after_cursor).to eq(dummies[2].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[2].id}")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before&per_page=3')

        expect(pagination_cursor.after_cursor).to eq(dummies[2].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[2].id}&per_page=3")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before')

        expect(pagination_cursor.after_cursor).to eq(dummies[2].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[2].id}")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before&per_page=3')

        expect(pagination_cursor.after_cursor).to eq(dummies[2].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[2].id}&per_page=3")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', cursor: dummies[2].id)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to eq(dummies[3].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[3].id}")

        expect(pagination_cursor.after_cursor).to eq(dummies[5].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[5].id}")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', cursor: dummies[2].id, per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to eq(dummies[3].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[3].id}&per_page=3")

        expect(pagination_cursor.after_cursor).to eq(dummies[5].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[5].id}&per_page=3")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', cursor: dummies[8].id)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to eq(dummies[9].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[9].id}")

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', cursor: dummies[8].id, per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to eq(dummies[9].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[9].id}&per_page=3")

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after&per_page=3')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before', cursor: dummies[9].id)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to eq(dummies[6].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[6].id}")

        expect(pagination_cursor.after_cursor).to eq(dummies[8].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[8].id}")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before', cursor: dummies[9].id, per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to eq(dummies[6].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[6].id}&per_page=3")

        expect(pagination_cursor.after_cursor).to eq(dummies[8].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[8].id}&per_page=3")
      end

      describe 'string, date, datetime, decimal, float column_type' do
        it 'returns accordingly' do
          dummies = [
            create(:dummy, uuid: SecureRandom.uuid, date: '2024-09-01', datetime: '2024-09-01T12:00:00.000001Z', decimal: '0.000001'.to_d, float: 0.000001), # index 0
            create(:dummy, uuid: SecureRandom.uuid, date: '2024-09-02', datetime: '2024-09-01T12:00:00.000002Z', decimal: '0.000002'.to_d, float: 0.000002), # index 1
            create(:dummy, uuid: SecureRandom.uuid, date: '2024-09-03', datetime: '2024-09-01T12:00:00.000003Z', decimal: '0.000003'.to_d, float: 0.000003), # index 2
            create(:dummy, uuid: SecureRandom.uuid, date: '2024-09-04', datetime: '2024-09-01T12:00:00.000004Z', decimal: '0.000004'.to_d, float: 0.000004), # index 3
            create(:dummy, uuid: SecureRandom.uuid, date: '2024-09-05', datetime: '2024-09-01T12:00:00.000005Z', decimal: '0.000005'.to_d, float: 0.000005), # index 4
          ]
          relation = Dummy.order(id: :desc)
          request = TestRequestHelper.build(url: 'http://test.upper.town/servers')

          pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 2, indicator: 'after', cursor: dummies[1].uuid, cursor_type: :string, cursor_column: :uuid)

          expect(pagination_cursor.start_cursor).to be_nil
          expect(pagination_cursor.start_cursor?).to be(false)
          expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

          expect(pagination_cursor.before_cursor).to eq(dummies[2].uuid)
          expect(pagination_cursor.has_before_cursor?).to be(true)
          expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[2].uuid}")

          expect(pagination_cursor.after_cursor).to eq(dummies[3].uuid)
          expect(pagination_cursor.has_after_cursor?).to be(true)
          expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[3].uuid}")

          pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 2, indicator: 'after', cursor: dummies[1].date, cursor_type: :date, cursor_column: :date)

          expect(pagination_cursor.start_cursor).to be_nil
          expect(pagination_cursor.start_cursor?).to be(false)
          expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

          expect(pagination_cursor.before_cursor).to eq(dummies[2].date)
          expect(pagination_cursor.has_before_cursor?).to be(true)
          expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[2].date.iso8601}")

          expect(pagination_cursor.after_cursor).to eq(dummies[3].date)
          expect(pagination_cursor.has_after_cursor?).to be(true)
          expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[3].date.iso8601}")

          pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 2, indicator: 'after', cursor: dummies[1].datetime, cursor_type: :datetime, cursor_column: :datetime)

          expect(pagination_cursor.start_cursor).to be_nil
          expect(pagination_cursor.start_cursor?).to be(false)
          expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

          expect(pagination_cursor.before_cursor).to eq(dummies[2].datetime)
          expect(pagination_cursor.has_before_cursor?).to be(true)
          expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{ERB::Util.url_encode(dummies[2].datetime.iso8601(6))}")

          expect(pagination_cursor.after_cursor).to eq(dummies[3].datetime)
          expect(pagination_cursor.has_after_cursor?).to be(true)
          expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{ERB::Util.url_encode(dummies[3].datetime.iso8601(6))}")

          pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 2, indicator: 'after', cursor: dummies[1].decimal, cursor_type: :decimal, cursor_column: :decimal)

          expect(pagination_cursor.start_cursor).to be_nil
          expect(pagination_cursor.start_cursor?).to be(false)
          expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

          expect(pagination_cursor.before_cursor).to eq(dummies[2].decimal)
          expect(pagination_cursor.has_before_cursor?).to be(true)
          expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[2].decimal}")

          expect(pagination_cursor.after_cursor).to eq(dummies[3].decimal)
          expect(pagination_cursor.has_after_cursor?).to be(true)
          expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[3].decimal}")

          pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 2, indicator: 'after', cursor: dummies[1].float, cursor_type: :float, cursor_column: :float)

          expect(pagination_cursor.start_cursor).to be_nil
          expect(pagination_cursor.start_cursor?).to be(false)
          expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

          expect(pagination_cursor.before_cursor).to eq(dummies[2].float)
          expect(pagination_cursor.has_before_cursor?).to be(true)
          expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{dummies[2].float}")

          expect(pagination_cursor.after_cursor).to eq(dummies[3].float)
          expect(pagination_cursor.has_after_cursor?).to be(true)
          expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{dummies[3].float}")
        end
      end
    end
  end
end
# rubocop:enable Rails/TimeZone
