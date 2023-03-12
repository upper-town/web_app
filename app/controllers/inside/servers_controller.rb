# frozen_string_literal: true

module Inside
  class ServersController < BaseController
    def index
      @servers = current_user_account.servers
    end

    def new
    end

    def create
    end
  end
end
