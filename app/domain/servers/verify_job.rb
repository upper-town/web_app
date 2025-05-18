module Servers
  class VerifyJob < ApplicationJob
    # TODO: rewrite lock: :while_executing)

    def perform(server)
      Verify.new(server).call
    end
  end
end
