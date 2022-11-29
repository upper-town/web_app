# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicId do
  describe '.from_uuid' do
    it 'converts UUID to PublicId' do
      given_uuid = '6bcaee2a-0275-4d2c-abca-bba6bd67c19b'
      expected_public_id = 'PUBMnwHjz6QL4jXKAtB6jB'

      expect(described_class.from_uuid(given_uuid)).to eq(expected_public_id)

      random_uuid = SecureRandom.uuid
      public_id = described_class.from_uuid(random_uuid)

      expect(public_id.count("^#{base58_chars.join}")).to eq(0)
    end
  end

  describe '.to_uuid' do
    it 'converts PublicId to UUID' do
      given_public_id = 'PUBMnwHjz6QL4jXKAtB6jB'
      expected_uuid = '6bcaee2a-0275-4d2c-abca-bba6bd67c19b'

      expect(described_class.to_uuid(given_public_id)).to eq(expected_uuid)

      random_base58_id = Base58Id.random_number
      uuid = described_class.to_uuid(random_base58_id)

      expect(uuid).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end
  end

  let(:base58_chars) do
    %w[
      A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
      a b c d e f g h i j k   m n o p q r s t u v w x y z
        1 2 3 4 5 6 7 8 9
    ]
  end
end
