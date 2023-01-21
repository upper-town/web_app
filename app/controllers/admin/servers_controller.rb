# frozen_string_literal: true

module Admin
  class ServersController < Admin::BaseController
    include Pagy::Backend

    def index
      @pagy, @servers = pagy(Admin::ServersQuery.new.call)
    rescue Pagy::OverflowError
      @servers = []

      render(status: :not_found)
    end

    def show
      @server = server_from_params
    end

    private

    def server_from_params
      Server.find(params['id'])
    end
  end
end
