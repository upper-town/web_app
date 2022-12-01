# frozen_string_literal: true

class Server < ApplicationRecord
  has_many :server_votes, dependent: :destroy
end
