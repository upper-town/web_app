require 'rails_helper'

RSpec.describe EmailValidator do
  it 'initializes with errors not empty before calling #valid?' do
    validator = described_class.new('user@example.com')

    expect(validator.errors).not_to be_empty
    expect(validator.errors).to include('not validated yet')
  end

  describe '#valid?' do
    context 'when email is not valid' do
      it 'returns false and set errors' do
        [
          nil,
          '',
          " \n  ",
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
          validator = described_class.new(invalid_email)

          expect(validator.valid?).to be(false)
          expect(validator.errors).not_to be_empty
          expect(validator.errors).to include('format is not valid')
        end

        invalid_long_email =
          'userxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52@' \
          'examplexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52.' \
          'com1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52.' \
          'com2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52.' \
          'com3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx52'

        validator = described_class.new(invalid_long_email)

        expect(validator.valid?).to be(false)
        expect(validator.errors).not_to be_empty
        expect(validator.errors).to include('format is not valid')
      end
    end

    context 'when email is valid' do
      it 'returns true and does not set errors' do
        [
          'user@example.com',
          'USER@EXAMPLE.COM',
          'user@example.com1.com2.com3',
          'user.test@example.com',
          'user_test@example.com'
        ].each do |valid_email|
          validator = described_class.new(valid_email)

          expect(validator.valid?).to be(true)
          expect(validator.errors).to be_empty
        end

        valid_long_email =
          'userxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51@' \
          'examplexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51.' \
          'com1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51.' \
          'com2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51.' \
          'com3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx51'

        validator = described_class.new(valid_long_email)

        expect(validator.valid?).to be(true)
        expect(validator.errors).to be_empty
      end
    end
  end

  describe '#email' do
    it 'returns the given email value string' do
      expect(described_class.new(nil).email).to eq('')
      expect(described_class.new('').email).to  eq('')

      expect(described_class.new('xxx').email).to eq('xxx')
      expect(described_class.new('user@example.com').email).to eq('user@example.com')
    end
  end
end
