# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pagination do
  describe '#page' do
    it 'gets page from options, clamps value' do
      relation = Dummy.all
      [
        [20,   nil, nil,  20],
        ['20', nil, nil,  20],
        [20,   10,  nil,  10],
        [20,   nil, 25,   25],
        [20,   nil, '25', 25],
        [20,   10,  25,   10],

        [ 1,   nil, nil, 1],
        [ '1', nil, nil, 1],
        [ 1,   nil, 5,   5],
        [ 1,   nil, '5', 5],
        [-1,   nil, nil, 1],
        ['-1', nil, nil, 1],
        [-1,   nil, 5,   5],
        [-1,   nil, '5', 5],

        [501, nil, nil,   200],
        [501, nil, 300,   200],
        [501, 300, nil,   300],
        [501, 300, 300,   300],
        [501, 300, '300', 300],

        [501, 1_000, nil,   500],
        [501, 1_000, 501,   500],
        [501, 1_000, 300,   300],
        [501, 1_000, '300', 300],
      ].each do |page, page_max, request_page_param, expected_page|
        request = TestRequestHelper.build(params: { 'page' => request_page_param })
        pagination = described_class.new(
          relation,
          request,
          page: page,
          page_max: page_max
        )

        expect(pagination.page).to eq(expected_page)
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
        pagination = described_class.new(
          relation,
          request,
          per_page: per_page,
          per_page_max: per_page_max,
          per_page_from_request: per_page_from_request
        )

        expect(pagination.per_page).to eq(expected_per_page), "Failed for #{per_page.inspect} and #{expected_per_page.inspect}"
      end
    end
  end

  describe '#offset' do
    it 'calculates offset according to per_page and page' do
      relation = Dummy.all
      request = TestRequestHelper.build
      [
        [20, 1,  0],
        [20, 2, 20],
        [20, 3, 40],
        [20, 4, 60],
      ].each do |per_page, page, expected_offset|
        pagination = described_class.new(
          relation,
          request,
          per_page: per_page,
          page: page
        )

        expect(pagination.offset).to eq(expected_offset)
      end
    end
  end

  describe '#results and #page_size' do
    describe 'order asc' do
      it 'takes per_page items from relation with offset for page' do
        dummies = create_list(:dummy, 10)
        relation = Dummy.order(id: :asc)
        request = TestRequestHelper.build

        pagination = described_class.new(relation, request, per_page: 3, page: 1)
        expect(pagination.results).to eq([dummies[0], dummies[1], dummies[2]])
        expect(pagination.page_size).to eq(3)

        pagination = described_class.new(relation, request, per_page: 3, page: 2)
        expect(pagination.results).to eq([dummies[3], dummies[4], dummies[5]])
        expect(pagination.page_size).to eq(3)

        pagination = described_class.new(relation, request, per_page: 3, page: 3)
        expect(pagination.results).to eq([dummies[6], dummies[7], dummies[8]])
        expect(pagination.page_size).to eq(3)

        pagination = described_class.new(relation, request, per_page: 3, page: 4)
        expect(pagination.results).to eq([dummies[9]])
        expect(pagination.page_size).to eq(1)

        pagination = described_class.new(relation, request, per_page: 3, page: 5)
        expect(pagination.results).to be_empty
        expect(pagination.page_size).to eq(0)
      end
    end

    describe 'order desc' do
      it 'takes per_page items from relation with offset for page' do
        dummies = create_list(:dummy, 10)
        relation = Dummy.order(id: :desc)
        request = TestRequestHelper.build

        pagination = described_class.new(relation, request, per_page: 3, page: 1)
        expect(pagination.results).to eq([dummies[9], dummies[8], dummies[7]])
        expect(pagination.page_size).to eq(3)

        pagination = described_class.new(relation, request, per_page: 3, page: 2)
        expect(pagination.results).to eq([dummies[6], dummies[5], dummies[4]])
        expect(pagination.page_size).to eq(3)

        pagination = described_class.new(relation, request, per_page: 3, page: 3)
        expect(pagination.results).to eq([dummies[3], dummies[2], dummies[1]])
        expect(pagination.page_size).to eq(3)

        pagination = described_class.new(relation, request, per_page: 3, page: 4)
        expect(pagination.results).to eq([dummies[0]])
        expect(pagination.page_size).to eq(1)

        pagination = described_class.new(relation, request, per_page: 3, page: 5)
        expect(pagination.results).to be_empty
        expect(pagination.page_size).to eq(0)
      end
    end
  end

  describe '#total_count, #total_pages, #last_page, #last_page?' do
    context 'when it is zero' do
      it 'returns accordingly' do
        create_list(:dummy, 10)
        relation = Dummy.all
        request = TestRequestHelper.build

        pagination = described_class.new(relation, request, total_count: 0, per_page: 3)

        expect(pagination.total_count).to eq(0)
        expect(pagination.total_pages).to eq(1)
        expect(pagination.last_page).to eq(1)
        expect(pagination.last_page?).to be(true)
      end
    end

    context 'when total_count option is given' do
      it 'returns it' do
        create_list(:dummy, 10)
        relation = Dummy.all
        request = TestRequestHelper.build

        pagination = described_class.new(relation, request, total_count: 100, per_page: 3)

        expect(pagination.total_count).to eq(100)
        expect(pagination.total_pages).to eq(34)
        expect(pagination.last_page).to eq(34)
        expect(pagination.last_page?).to be(false)

        pagination = described_class.new(relation, request, total_count: 100, per_page: 3, page: 34)

        expect(pagination.total_count).to eq(100)
        expect(pagination.total_pages).to eq(34)
        expect(pagination.last_page).to eq(34)
        expect(pagination.last_page?).to be(true)
      end
    end

    context 'when total_count option is not given' do
      it 'returns relation count' do
        create_list(:dummy, 10)
        relation = Dummy.all
        request = TestRequestHelper.build

        pagination = described_class.new(relation, request, total_count: nil, per_page: 3, page: 1)

        expect(pagination.total_count).to eq(10)
        expect(pagination.total_pages).to eq(4)
        expect(pagination.last_page).to eq(4)
        expect(pagination.last_page?).to be(false)

        pagination = described_class.new(relation, request, total_count: nil, per_page: 3, page: 4)

        expect(pagination.total_count).to eq(10)
        expect(pagination.total_pages).to eq(4)
        expect(pagination.last_page).to eq(4)
        expect(pagination.last_page?).to be(true)
      end
    end
  end

  describe '#first_page and #first_page?' do
    it 'returns accordingly' do
      create_list(:dummy, 10)
      relation = Dummy.all
      request = TestRequestHelper.build

      pagination = described_class.new(relation, request, per_page: 4, page: 1)
      expect(pagination.first_page).to eq(1)
      expect(pagination.first_page?).to be(true)

      pagination = described_class.new(relation, request, per_page: 4, page: 2)
      expect(pagination.first_page).to eq(1)
      expect(pagination.first_page?).to be(false)
    end
  end

  describe '#prev_page and #has_prev_page?' do
    it 'returns accordingly' do
      [
        [-1, 1, false],
        [ 0, 1, false],
        [ 1, 1, false],
        [ 2, 1, true],
        [ 3, 2, true],
        [ 4, 3, true],
        [10, 9, true],
      ].each do |page, expected_prev_page, expected_has_prev_page|
        relation = Dummy.all
        request = TestRequestHelper.build
        pagination = described_class.new(relation, request, page: page)

        expect(pagination.prev_page).to eq(expected_prev_page)
        expect(pagination.has_prev_page?).to be(expected_has_prev_page)
      end
    end
  end

  describe '#next_page and #has_next_page?' do
    context 'when page_size is less than per_page' do
      it 'returns page' do
        relation = Dummy.all
        request = TestRequestHelper.build
        pagination = described_class.new(relation, request, per_page: 10, page: 1)

        expect(pagination.next_page).to eq(1)
        expect(pagination.has_next_page?).to be(false)
      end
    end

    context 'when relation_plus_one.size is less than per_page' do
      it 'returns page' do
        create_list(:dummy, 4)
        relation = Dummy.all
        request = TestRequestHelper.build
        pagination = described_class.new(relation, request, per_page: 5, page: 1)

        expect(pagination.next_page).to eq(1)
        expect(pagination.has_next_page?).to be(false)
      end
    end

    context 'when relation_plus_one.size is equal to per_page' do
      it 'returns page' do
        create_list(:dummy, 5)
        relation = Dummy.all
        request = TestRequestHelper.build
        pagination = described_class.new(relation, request, per_page: 5, page: 1)

        expect(pagination.next_page).to eq(1)
        expect(pagination.has_next_page?).to be(false)
      end
    end

    context 'when relation_plus_one.size is greater than per_page' do
      it 'returns page + 1 or respects page_max' do
        create_list(:dummy, 6)
        relation = Dummy.all
        request = TestRequestHelper.build

        pagination = described_class.new(relation, request, per_page: 5, page: 1)
        expect(pagination.next_page).to eq(2)
        expect(pagination.has_next_page?).to be(true)

        pagination = described_class.new(relation, request, per_page: 5, page: 1, page_max: 1)
        expect(pagination.next_page).to eq(1)
        expect(pagination.has_next_page?).to be(false)
      end
    end
  end

  describe '#first_page_url, #prev_page_url, #page_url, #next_page_url, #last_page_url' do
    it 'returns accordingly' do
      create_list(:dummy, 10)
      relation = Dummy.all
      request = TestRequestHelper.build(url: 'http://test.upper.town/servers')

      pagination = described_class.new(relation, request, per_page: 4, page: 1)
      expect(pagination.first_page_url).to eq('http://test.upper.town/servers?page=1')
      expect(pagination.prev_page_url).to eq('http://test.upper.town/servers?page=1')
      expect(pagination.page_url(1)).to eq('http://test.upper.town/servers?page=1')
      expect(pagination.next_page_url).to eq('http://test.upper.town/servers?page=2')
      expect(pagination.last_page_url).to eq('http://test.upper.town/servers?page=3')

      pagination = described_class.new(relation, request, per_page: 4, page: 1, per_page_from_request: true)
      expect(pagination.first_page_url).to eq('http://test.upper.town/servers?page=1&per_page=4')
      expect(pagination.prev_page_url).to eq('http://test.upper.town/servers?page=1&per_page=4')
      expect(pagination.page_url(1)).to eq('http://test.upper.town/servers?page=1&per_page=4')
      expect(pagination.next_page_url).to eq('http://test.upper.town/servers?page=2&per_page=4')
      expect(pagination.last_page_url).to eq('http://test.upper.town/servers?page=3&per_page=4')

      pagination = described_class.new(relation, request, per_page: 4, page: 2)
      expect(pagination.first_page_url).to eq('http://test.upper.town/servers?page=1')
      expect(pagination.prev_page_url).to eq('http://test.upper.town/servers?page=1')
      expect(pagination.page_url(2)).to eq('http://test.upper.town/servers?page=2')
      expect(pagination.next_page_url).to eq('http://test.upper.town/servers?page=3')
      expect(pagination.last_page_url).to eq('http://test.upper.town/servers?page=3')

      pagination = described_class.new(relation, request, per_page: 4, page: 2, per_page_from_request: true)
      expect(pagination.first_page_url).to eq('http://test.upper.town/servers?page=1&per_page=4')
      expect(pagination.prev_page_url).to eq('http://test.upper.town/servers?page=1&per_page=4')
      expect(pagination.page_url(2)).to eq('http://test.upper.town/servers?page=2&per_page=4')
      expect(pagination.next_page_url).to eq('http://test.upper.town/servers?page=3&per_page=4')
      expect(pagination.last_page_url).to eq('http://test.upper.town/servers?page=3&per_page=4')

      pagination = described_class.new(relation, request, per_page: 4, page: 3)
      expect(pagination.first_page_url).to eq('http://test.upper.town/servers?page=1')
      expect(pagination.prev_page_url).to eq('http://test.upper.town/servers?page=2')
      expect(pagination.page_url(3)).to eq('http://test.upper.town/servers?page=3')
      expect(pagination.next_page_url).to eq('http://test.upper.town/servers?page=3')
      expect(pagination.last_page_url).to eq('http://test.upper.town/servers?page=3')

      pagination = described_class.new(relation, request, per_page: 4, page: 3, per_page_from_request: true)
      expect(pagination.first_page_url).to eq('http://test.upper.town/servers?page=1&per_page=4')
      expect(pagination.prev_page_url).to eq('http://test.upper.town/servers?page=2&per_page=4')
      expect(pagination.page_url(3)).to eq('http://test.upper.town/servers?page=3&per_page=4')
      expect(pagination.next_page_url).to eq('http://test.upper.town/servers?page=3&per_page=4')
      expect(pagination.last_page_url).to eq('http://test.upper.town/servers?page=3&per_page=4')
    end
  end
end
