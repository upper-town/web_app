# frozen_string_literal: true

module Servers
  class VerifyJob < ApplicationJob
    def perform(server)
      Verify.new(server).call
    end
  end
end
