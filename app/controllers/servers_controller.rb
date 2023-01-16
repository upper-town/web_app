# frozen_string_literal: true

class ServersController < ApplicationController
  def index
    @servers = Servers::IndexQuery.new.call
  end
end
