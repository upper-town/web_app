# frozen_string_literal: true

require "test_helper"

class ServerBannerImageUploadedFileTest < ActiveSupport::TestCase
  let(:described_class) { ServerBannerImageUploadedFile }

  describe "validations" do
    it "validates byte_size" do
      instance = described_class.new(uploaded_file: nil)
      instance.validate
      assert(instance.errors.key?(:byte_size).blank?)

      instance = described_class.new(uploaded_file: StringIO.new("aaa"))
      instance.validate
      assert(instance.errors.key?(:byte_size).blank?)

      instance = described_class.new(uploaded_file: StringIO.new("a" * 512 * 1024))
      instance.validate
      assert(instance.errors.key?(:byte_size).blank?)

      instance = described_class.new(uploaded_file: StringIO.new(("a" * 512 * 1024) + "a"))
      instance.validate
      assert(instance.errors.key?(:byte_size).present?)
      assert(instance.errors[:byte_size].any? { it.match?(/File size is too large. Maximum allowed size/) })
    end

    it "validates content_type" do
      instance = described_class.new(uploaded_file: nil)
      instance.validate
      assert(instance.errors.key?(:content_type).blank?)

      instance = described_class.new(uploaded_file: StringIO.new("aaa"))
      instance.validate
      assert(instance.errors.key?(:content_type).present?)
      assert(instance.errors[:content_type].any? { it.match?(/Invalid content type. Allowed types/) })

      instance = described_class.new(uploaded_file: StringIO.new(png_1px))
      instance.validate
      assert(instance.errors.key?(:content_type).blank?)

      instance = described_class.new(uploaded_file: StringIO.new(jpeg_1px))
      instance.validate
      assert(instance.errors.key?(:content_type).blank?)
    end
  end

  describe "#present?, #blank?, #presence" do
    it "delegates to uploaded_file" do
      uploaded_file = nil
      instance = described_class.new(uploaded_file:)

      assert(instance.blank?)
      assert_not(instance.present?)
      assert_nil(instance.presence)

      uploaded_file = StringIO.new("aaa")
      instance = described_class.new(uploaded_file:)

      assert_not(instance.blank?)
      assert(instance.present?)
      assert_equal(uploaded_file, instance.presence)
    end
  end

  describe "#blob" do
    it "returns nil or reads and returns content" do
      instance = described_class.new(uploaded_file: nil)
      assert_nil(instance.blob)

      instance = described_class.new(uploaded_file: StringIO.new("aaa"))
      assert_equal("aaa", instance.blob)
    end
  end

  describe "#byte_size" do
    it "returns nil or number of bytes from blob" do
      instance = described_class.new(uploaded_file: nil)
      assert_nil(instance.byte_size)

      instance = described_class.new(uploaded_file: StringIO.new(""))
      assert_equal(0, instance.byte_size)

      instance = described_class.new(uploaded_file: StringIO.new("aaa"))
      assert_equal(3, instance.byte_size)
    end
  end

  describe "#content_type" do
    it "returns nil or infers and returns mime type from blob" do
      instance = described_class.new(uploaded_file: nil)
      assert_nil(instance.content_type)

      instance = described_class.new(uploaded_file: StringIO.new("aaa"))
      assert_equal("application/octet-stream", instance.content_type)

      instance = described_class.new(uploaded_file: StringIO.new(png_1px))
      assert_equal("image/png", instance.content_type)

      instance = described_class.new(uploaded_file: StringIO.new(jpeg_1px))
      assert_equal("image/jpeg", instance.content_type)
    end
  end

  describe "#checksum" do
    it "returns nil or calculates and returns digest from blob" do
      instance = described_class.new(uploaded_file: nil)
      assert_nil(instance.checksum)

      instance = described_class.new(uploaded_file: StringIO.new("aaa"))
      assert_equal(Digest::SHA256.hexdigest("aaa"), instance.checksum)

      instance = described_class.new(uploaded_file: StringIO.new(png_1px))
      assert_equal(Digest::SHA256.hexdigest(png_1px), instance.checksum)

      instance = described_class.new(uploaded_file: StringIO.new(jpeg_1px))
      assert_equal(Digest::SHA256.hexdigest(jpeg_1px), instance.checksum)
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
