# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ValidateEmail do
  it 'initializes with errors not empty before calling #valid? or #invalid?' do
    validator = described_class.new('user@gmail.com')

    expect(validator.errors).to include(:not_validated_yet)
  end

  describe '#valid? and #invalid?' do
    context 'when email format is not valid' do
      it 'returns false and set errors' do
        [
          nil,
          '',
          " \n\t",
          'user',
          'user@',
          'user@gmail',
          'user@sub1.sub2.sub3.sub4.gmail.com',
          '.user@@gmail.com',
          '_user@@gmail.com',
          'user@@gmail.com',
          'user#@gmail.com',
          'user+test@gmail.com',
          'user,test@gmail.com'
        ].each do |invalid_email|
          validator = described_class.new(invalid_email)

          expect(validator.valid?).to(be(false), "Failed for #{invalid_email.inspect}")
          expect(validator.invalid?).to be(true)
          expect(validator.errors).to include(:format_is_not_valid)
        end
      end

      it 'returns false and set errors for long email' do
        invalid_long_email =
          'userxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@' \
          'sub1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.' \
          'sub2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.' \
          'sub3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.' \
          'googlexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.' \
          'comxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

        validator = described_class.new(invalid_long_email)

        expect(validator.valid?).to be(false)
        expect(validator.invalid?).to be(true)
        expect(validator.errors).to include(:format_is_not_valid)
      end
    end

    describe 'reserved names' do
      context 'when email contains reserved name' do
        it 'returns accordingly' do
          %w[
            corp
            domain
            example
            home
            host
            internal
            intranet
            invalid
            lan
            local
            localdomain
            localhost
            onion
            private
            test
          ].each do |reserved_name|
            [
              [false, "user@sub.#{reserved_name}"],
              [false, "user@#{reserved_name}.com"],

              [false, "user@sub.sub.#{reserved_name}"],
              [false, "user@sub.#{reserved_name}.com"],
              [false, "user@#{reserved_name}.sub.com"],

              [false, "user@sub.sub.sub.#{reserved_name}"],
              [false, "user@sub.sub.#{reserved_name}.com"],
              [false, "user@sub.#{reserved_name}.sub.com"],
              [true,  "user@#{reserved_name}.sub.sub.com"],

              [false, "user@sub.sub.sub.sub.#{reserved_name}"],
              [false, "user@sub.sub.sub.#{reserved_name}.com"],
              [false, "user@sub.sub.#{reserved_name}.sub.com"],
              [true,  "user@sub.#{reserved_name}.sub.sub.com"],
              [true,  "user@#{reserved_name}.sub.sub.sub.com"],
            ].each do |valid, email_with_reserved_domain|
              validator = described_class.new(email_with_reserved_domain)

              if valid
                expect(validator.valid?).to(
                  be(true), "Failed for #{reserved_name.inspect} and #{email_with_reserved_domain.inspect}"
                )
                expect(validator.invalid?).to be(false)
                expect(validator.errors).to be_empty
              else
                expect(validator.valid?).to(
                  be(false), "Failed for #{reserved_name.inspect} and #{email_with_reserved_domain.inspect}"
                )
                expect(validator.invalid?).to be(true)
                expect(validator.errors).to include(:domain_is_not_supported)
              end
            end
          end
        end
      end
    end

    context 'when email domain is from a disposable email service' do
      it 'returns false and set errors' do
        file_path = Rails.root.join('vendor/disposable_email_domains/list_test.txt')

        File.foreach(file_path, chomp: true) do |disposable_email_host|
          disposable_email = "user@#{disposable_email_host}"

          validator = described_class.new(disposable_email)

          expect(validator.valid?).to be(false)
          expect(validator.invalid?).to be(true)
          expect(validator.errors).to include(:domain_is_not_supported)
        end
      end
    end

    context 'when email is valid' do
      it 'returns true and does not set errors' do
        [
          'user@gmail.com',
          'USER@GMAIL.COM',
          'user@sub1.sub2.sub3.gmail.com',
          'user.test@gmail.com',
          'user-test@gmail.com',
          'user_test@gmail.com',
          'userxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@' \
            'gmailxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.' \
            'com1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.' \
            'com2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.' \
            'com3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
        ].each do |valid_email|
          validator = described_class.new(valid_email)

          expect(validator.valid?).to(be(true), "Failed for #{valid_email.inspect}")
          expect(validator.invalid?).to be(false)
          expect(validator.errors).to be_empty
        end
      end
    end
  end

  describe '#email' do
    it 'returns the given email value string' do
      expect(described_class.new(nil).email).to eq('')
      expect(described_class.new('').email).to  eq('')

      expect(described_class.new('abcdef').email).to eq('abcdef')
      expect(described_class.new('user@upper.town').email).to eq('user@upper.town')
    end
  end
end
