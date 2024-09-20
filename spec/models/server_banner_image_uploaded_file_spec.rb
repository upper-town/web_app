# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerBannerImageUploadedFile do
  describe 'validations' do
    it 'validates byte_size' do
      instance = described_class.new(uploaded_file: nil)
      instance.validate
      expect(instance.errors.key?(:byte_size)).to be_blank

      instance = described_class.new(uploaded_file: StringIO.new('aaa'))
      instance.validate
      expect(instance.errors.key?(:byte_size)).to be_blank

      instance = described_class.new(uploaded_file: StringIO.new('a' * 512 * 1024))
      instance.validate
      expect(instance.errors.key?(:byte_size)).to be_blank

      instance = described_class.new(uploaded_file: StringIO.new(('a' * 512 * 1024) + 'a'))
      instance.validate
      expect(instance.errors.key?(:byte_size)).to be_present
      expect(instance.errors[:byte_size]).to include(/File size is too large. Maximum allowed size/)
    end

    it 'validates content_type' do
      instance = described_class.new(uploaded_file: nil)
      instance.validate
      expect(instance.errors.key?(:content_type)).to be_blank

      instance = described_class.new(uploaded_file: StringIO.new('aaa'))
      instance.validate
      expect(instance.errors.key?(:content_type)).to be_present
      expect(instance.errors[:content_type]).to include(/Invalid content type. Allowed types/)

      instance = described_class.new(uploaded_file: StringIO.new(png_1px))
      instance.validate
      expect(instance.errors.key?(:content_type)).to be_blank

      instance = described_class.new(uploaded_file: StringIO.new(jpeg_1px))
      instance.validate
      expect(instance.errors.key?(:content_type)).to be_blank
    end
  end

  describe '#present?, #blank?, #presence' do
    it 'delegates to uploaded_file' do
      uploaded_file = nil
      instance = described_class.new(uploaded_file: uploaded_file)

      expect(instance).to be_blank
      expect(instance).not_to be_present
      expect(instance.presence).to be_nil

      uploaded_file = StringIO.new('aaa')
      instance = described_class.new(uploaded_file: uploaded_file)

      expect(instance).not_to be_blank
      expect(instance).to be_present
      expect(instance.presence).to be(uploaded_file)
    end
  end

  describe '#blob' do
    it 'returns nil or reads and returns content' do
      instance = described_class.new(uploaded_file: nil)
      expect(instance.blob).to be_nil

      instance = described_class.new(uploaded_file: StringIO.new('aaa'))
      expect(instance.blob).to eq('aaa')
    end
  end

  describe '#byte_size' do
    it 'returns nil or number of bytes from blob' do
      instance = described_class.new(uploaded_file: nil)
      expect(instance.byte_size).to be_nil

      instance = described_class.new(uploaded_file: StringIO.new(''))
      expect(instance.byte_size).to eq(0)

      instance = described_class.new(uploaded_file: StringIO.new('aaa'))
      expect(instance.byte_size).to eq(3)
    end
  end

  describe '#content_type' do
    it 'returns nil or infers and returns mime type from blob' do
      instance = described_class.new(uploaded_file: nil)
      expect(instance.content_type).to be_nil

      instance = described_class.new(uploaded_file: StringIO.new('aaa'))
      expect(instance.content_type).to eq('application/octet-stream')

      instance = described_class.new(uploaded_file: StringIO.new(png_1px))
      expect(instance.content_type).to eq('image/png')

      instance = described_class.new(uploaded_file: StringIO.new(jpeg_1px))
      expect(instance.content_type).to eq('image/jpeg')
    end
  end

  describe '#checksum' do
    it 'returns nil or calculates and returns digest from blob' do
      instance = described_class.new(uploaded_file: nil)
      expect(instance.checksum).to be_nil

      instance = described_class.new(uploaded_file: StringIO.new('aaa'))
      expect(instance.checksum).to eq(Digest::SHA256.hexdigest('aaa'))

      instance = described_class.new(uploaded_file: StringIO.new(png_1px))
      expect(instance.checksum).to eq(Digest::SHA256.hexdigest(png_1px))

      instance = described_class.new(uploaded_file: StringIO.new(jpeg_1px))
      expect(instance.checksum).to eq(Digest::SHA256.hexdigest(jpeg_1px))
    end
  end

  let(:png_1px) do
    "\x89PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\b" \
    "\x06\x00\x00\x00\x1F\x15\xC4\x89\x00\x00\x00\rIDATx\xDAc\xFC\xCF\xC0P" \
    "\x0F\x00\x04\x85\x01\x80\x84\xA9\x8C!\x00\x00\x00\x00IEND\xAEB`\x82"
  end

  let(:jpeg_1px) do
    "\xFF\xD8\xFF\xDB\x00C\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF" \
    "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF" \
    "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF" \
    "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF" \
    "\xFF\xFF\xFF\xC0\x00\v\b\x00\x01\x00\x01\x01\x01\x11\x00\xFF\xC4\x00" \
    "\x14\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x03\xFF\xC4\x00\x14\x10\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\xFF\xDA\x00\b\x01\x01\x00\x00?\x007\xFF\xD9"
  end
end
