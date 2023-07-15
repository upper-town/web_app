# frozen_string_literal: true

module Servers
  class NewForm < ApplicationForm
    attribute :app_id,       :string # suuid
    attribute :country_code, :string
    attribute :name,         :string
    attribute :site_url,     :string

    def method
      :post
    end

    def url
      inside_servers_path
    end
  end
end
