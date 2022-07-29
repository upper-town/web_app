require 'rails_helper'

RSpec.describe EmailRecordValidator do
  describe '#validate' do
    context 'when record has an invalid email' do
      it 'set record.errors' do
        [
          'user',
          'user@',
          'user@example',
          'user@example.com1.com2.com3.com4',
          '.user@@example.com',
          '_user@@example.com',
          'user@@example.com',
          'user#@example.com',
          'user+test@example.com',
          'user-test@example.com',
          'user,test@example.com'
        ].each do |invalid_email|
          record = generic_active_record_class.new(email: invalid_email)

          validator = described_class.new(record)
          validator.validate

          expect(record.errors).not_to be_empty
          expect(record.errors.messages[:email]).to include('format is not valid')
        end

        invalid_long_email =
          'userxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52@' \
          'examplexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52.' \
          'com1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52.' \
          'com2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52.' \
          'com3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52'

        record = generic_active_record_class.new(email: invalid_long_email)

        validator = described_class.new(record)
        validator.validate

        expect(record.errors).not_to be_empty
        expect(record.errors.messages[:email]).to include('format is not valid')
      end
    end

    context 'when record has a valid email' do
      it 'does not set errors' do
        [
          nil,
          '',
          " \n  ",

          'user@example.com',
          'USER@EXAMPLE.COM',
          'user@example.com1.com2.com3',
          'user.test@example.com',
          'user_test@example.com'
        ].each do |valid_email|
          record = generic_active_record_class.new(email: valid_email)

          validator = described_class.new(record)
          validator.validate

          expect(record.errors).to be_empty
        end

        valid_long_email =
          'userxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51@' \
          'examplexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51.' \
          'com1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51.' \
          'com2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51.' \
          'com3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51'

        record = generic_active_record_class.new(email: valid_long_email)

        validator = described_class.new(record)
        validator.validate

        expect(record.errors).to be_empty
      end
    end

    describe 'passing :attribute_name options' do
      it 'uses the attribute_name from options instead of :email' do
        record = generic_active_record_class.new(other: 'invalid_email')

        validator = described_class.new(record, attribute_name: :other)
        validator.validate

        expect(record.errors).not_to be_empty
        expect(record.errors.messages[:other]).to include('format is not valid')
      end
    end
  end

  def generic_active_record_class
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      include ActiveModel::Attributes

      attribute :email
      attribute :other
    end
  end
end
