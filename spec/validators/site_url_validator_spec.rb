# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteUrlValidator do
  describe '#validate' do
    context 'when record has an invalid site_url' do
      it 'sets record.errors' do
        record = generic_model_class.new(site_url: 'abcdef')

        validator = described_class.new(attributes: [:site_url])
        validator.validate(record)

        expect(record.errors.of_kind?(:site_url, :format_is_not_valid)).to be(true)
      end
    end

    context 'when record has a blank site_url' do
      it 'does not record.errors' do
        record = generic_model_class.new(site_url: ' ')

        validator = described_class.new(attributes: [:site_url])
        validator.validate(record)

        expect(record.errors.of_kind?(:site_url)).to be(false)
      end
    end

    context 'when record has a valid site_url' do
      it 'does not set errors' do
        record = generic_model_class.new(site_url: 'https://example.com/')

        validator = described_class.new(attributes: [:site_url])
        validator.validate(record)

        expect(record.errors.of_kind?(:site_url)).to be(false)
      end
    end
  end

  def generic_model_class
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      def self.name
        'GenericModelClass'
      end

      attribute :site_url
      attribute :other
    end
  end
end
