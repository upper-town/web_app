# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailValidator do
  it 'initializes with errors not empty before calling #valid?' do
    validator = described_class.new('user@upper.town')

    expect(validator.errors).not_to be_empty
    expect(validator.errors).to include('not validated yet')
  end

  describe '#valid?' do
    context 'when email format is not valid' do
      it 'returns false and set errors' do
        [
          nil,
          '',
          " \n  ",
          'user',
          'user@',
          'user@google',
          'user@google.com1.com2.com3.com4',
          '.user@@google.com',
          '_user@@google.com',
          'user@@google.com',
          'user#@google.com',
          'user+test@google.com',
          'user,test@google.com'
        ].each do |invalid_email|
          validator = described_class.new(invalid_email)

          expect(validator.valid?).to be(false)
          expect(validator.errors).not_to be_empty
          expect(validator.errors).to include('format is not valid')
        end

        invalid_long_email =
          'userxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52@' \
          'googlexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52.' \
          'com1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52.' \
          'com2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52.' \
          'com3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52'

        validator = described_class.new(invalid_long_email)

        expect(validator.valid?).to be(false)
        expect(validator.errors).not_to be_empty
        expect(validator.errors).to include('format is not valid')
      end
    end

    context 'when email domain is reserved' do
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
        it "returns false and set errors for email with reserved name \"#{reserved_name}\"" do
          [
            "user@sub.#{reserved_name}",
            "user@#{reserved_name}.com",

            "user@sub.sub.#{reserved_name}",
            "user@sub.#{reserved_name}.com",
            "user@#{reserved_name}.com.br",

            "user@sub.sub.sub.#{reserved_name}",
            "user@sub.sub.#{reserved_name}.com",
            "user@sub.#{reserved_name}.com.br",
          ].each do |email_with_reserved_domain|
            validator = described_class.new(email_with_reserved_domain)

            expect(validator.valid?).to be(false)
            expect(validator.errors).not_to be_empty
            expect(validator.errors).to include('domain is not valid')
          end
        end

        it "returns true and does not set errors for email looks like \"#{reserved_name}\"" do
          [
            "user@#{reserved_name}.abc.com.br",

            "user@sub.#{reserved_name}abc",
            "user@#{reserved_name}abc.com",

            "user@sub.sub.#{reserved_name}abc",
            "user@sub.#{reserved_name}abc.com",
            "user@#{reserved_name}abc.com.br",

            "user@sub.sub.sub.#{reserved_name}abc",
            "user@sub.sub.#{reserved_name}abc.com",
            "user@sub.#{reserved_name}abc.com.br",
          ].each do |email_looks_like_reserved_name|
            validator = described_class.new(email_looks_like_reserved_name)

            expect(validator.valid?).to be(true)
            expect(validator.errors).to be_empty
          end
        end
      end
    end

    context 'when email domain is from a disposable email service' do
      it 'returns false and set errors' do
        file_path = Rails.root.join('vendor/disposable_email_domains/list.txt')

        File.foreach(file_path, chomp: true) do |disposable_email_host|
          disposable_email = "user@#{disposable_email_host}"

          validator = described_class.new(disposable_email)

          expect(validator.valid?).to be(false)
          expect(validator.errors).not_to be_empty
          expect(validator.errors).to include('domain is not valid')
        end
      end
    end

    context 'when email is valid' do
      [
        'user@google.com',
        'USER@GOOGLE.COM',
        'user@google.com1.com2.com3',
        'user.test@google.com',
        'user-test@google.com',
        'user_test@google.com',
        'userxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51@' \
          'googlexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51.' \
          'com1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51.' \
          'com2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51.' \
          'com3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51',
      ].each do |valid_email|
        it "returns true and does not set errors for #{valid_email}" do
          validator = described_class.new(valid_email)

          expect(validator.valid?).to be(true)
          expect(validator.errors).to be_empty
        end
      end
    end
  end

  describe '#email' do
    it 'returns the given email value string' do
      expect(described_class.new(nil).email).to eq('')
      expect(described_class.new('').email).to  eq('')

      expect(described_class.new('xxx').email).to eq('xxx')
      expect(described_class.new('user@upper.town').email).to eq('user@upper.town')
    end
  end
end
