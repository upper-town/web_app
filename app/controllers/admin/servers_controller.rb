# frozen_string_literal: true

module Admin
  class ServersController < BaseController
    def index
      @pagination = Pagination.new(Admin::ServersQuery.new.call, request, per_page: 50)
      @servers = @pagination.results

      render(status: @servers.empty? ? :not_found : :ok)
    end

    def show
      @server = server_from_params
    end

    private

    def server_from_params
      Server.find(params[:id])
    end
  end
end
