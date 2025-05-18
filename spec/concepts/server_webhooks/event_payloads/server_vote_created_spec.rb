require 'rails_helper'

RSpec.describe ServerWebhooks::EventPayloads::ServerVoteCreated do
  describe '#call' do
    it 'returns hash with server_vote data' do
      game = create(:game)
      server = create(:server)

      server_vote1 = create(
        :server_vote,
        game: game,
        server: server,
        country_code: 'US',
        reference: 'anything123456',
        remote_ip: '1.1.1.1',
        account: nil,
        created_at: Time.iso8601('2024-09-02T12:00:01Z')
      )
      returned = described_class.new(server_vote1).call

      expect(returned).to eq(
        {
          'server_vote' => {
            'uuid'         => server_vote1.uuid,
            'game_id'      => game.id,
            'server_id'    => server.id,
            'country_code' => 'US',
            'reference'    => 'anything123456',
            'remote_ip'    => '1.1.1.1',
            'account_uuid' => nil,
            'created_at'   => '2024-09-02T12:00:01Z'
          }
        }
      )

      account = create(:account)
      server_vote2 = create(
        :server_vote,
        game: game,
        server: server,
        country_code: 'US',
        reference: 'anything123456',
        remote_ip: '1.1.1.1',
        account: account,
        created_at: Time.iso8601('2024-09-02T12:00:01Z')
      )
      returned = described_class.new(server_vote2).call

      expect(returned).to eq(
        {
          'server_vote' => {
            'uuid'         => server_vote2.uuid,
            'game_id'      => game.id,
            'server_id'    => server.id,
            'country_code' => 'US',
            'reference'    => 'anything123456',
            'remote_ip'    => '1.1.1.1',
            'account_uuid' => account.uuid,
            'created_at'   => '2024-09-02T12:00:01Z'
          }
        }
      )
    end
  end
end
