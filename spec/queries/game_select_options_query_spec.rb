# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameSelectOptionsQuery do
  describe '#call' do
    context 'when only_in_use is false' do
      it 'returns options with label and value for all games' do
        game1 = create(:game, name: 'Ccc')
        create(:server, game: game1)
        create(:server, game: game1)
        game2 = create(:game, name: 'Aaa')
        game3 = create(:game, name: 'Bbb')
        create(:server, game: game3)

        expect(described_class.new.call).to eq([
          ['Aaa', game2.id],
          ['Bbb', game3.id],
          ['Ccc', game1.id],
        ])
      end
    end

    context 'when only_in_use is true' do
      it 'returns options with label and value only for games that have servers' do
        game1 = create(:game, name: 'Ccc')
        create(:server, game: game1)
        create(:server, game: game1)
        _game2 = create(:game, name: 'Aaa')
        game3 = create(:game, name: 'Bbb')
        create(:server, game: game3)

        expect(described_class.new(only_in_use: true).call).to eq([
          ['Bbb', game3.id],
          ['Ccc', game1.id],
        ])
      end
    end

    describe 'with cache_enabled' do
      it 'caches result' do
        game1 = create(:game, name: 'Ccc')
        create(:server, game: game1)
        create(:server, game: game1)
        game2 = create(:game, name: 'Aaa')
        game3 = create(:game, name: 'Bbb')
        create(:server, game: game3)
        allow(Rails.cache)
          .to receive(:fetch)

        described_class.new(only_in_use: true, cache_enabled: true).call

        expect(Rails.cache)
          .to have_received(:fetch)
          .with('game_select_options_query:only_in_use', expires_in: 5.minutes) do |&block|
            expect(block.call).to eq([
              ['Bbb', game3.id],
              ['Ccc', game1.id],
            ])
          end

        described_class.new(only_in_use: false, cache_enabled: true).call

        expect(Rails.cache)
          .to have_received(:fetch)
          .with('game_select_options_query', expires_in: 5.minutes) do |&block|
            expect(block.call).to eq([
              ['Aaa', game2.id],
              ['Bbb', game3.id],
              ['Ccc', game1.id],
            ])
          end
      end
    end
  end
end
