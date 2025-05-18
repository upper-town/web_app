require 'rails_helper'

RSpec.describe Servers::Verify do
  describe '#call' do
    context 'when VerifyAccounts::Perform suceeds' do
      it 'updates server as verified' do
        freeze_time do
          server = create(:server, verified_at: nil, verified_notice: 'something')
          verify_accounts_perform = instance_double(Servers::VerifyAccounts::Perform)
          allow(Servers::VerifyAccounts::Perform)
            .to receive(:new)
            .and_return(verify_accounts_perform)
          allow(verify_accounts_perform)
            .to receive(:call)
            .and_return(Result.success)

          described_class.new(server).call

          server.reload
          expect(server.verified_at).to eq(Time.current)
          expect(server.verified_notice).to eq('')

          expect(Servers::VerifyAccounts::Perform)
            .to have_received(:new)
            .with(server)
          expect(verify_accounts_perform)
            .to have_received(:call)
            .with(Time.current)
        end
      end
    end

    context 'when VerifyAccounts::Perform fails' do
      it 'updates server as not verified' do
        server = create(:server, verified_at: Time.current, verified_notice: '')
        verify_accounts_perform = instance_double(Servers::VerifyAccounts::Perform)
        allow(Servers::VerifyAccounts::Perform)
          .to receive(:new)
          .and_return(verify_accounts_perform)
        allow(verify_accounts_perform)
          .to receive(:call)
          .and_return(Result.failure([ 'an error', 'another error' ]))

        described_class.new(server).call

        server.reload
        expect(server.verified_at).to be_nil
        expect(server.verified_notice).to eq('an error; another error')

        expect(Servers::VerifyAccounts::Perform)
          .to have_received(:new)
          .with(server)
        expect(verify_accounts_perform)
          .to have_received(:call)
      end
    end
  end
end
