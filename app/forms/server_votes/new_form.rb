# frozen_string_literal: true

module ServerVotes
  class NewForm < ApplicationForm
    attribute :reference_id, :string, default: ''

    validates :reference_id, length: { maximum: 255 }

    def method
      :post
    end

    def url(server)
      server_votes_path(server.suuid)
    end
  end
end
