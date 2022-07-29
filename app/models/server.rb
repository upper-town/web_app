class Server < ApplicationRecord
  has_many :server_votes, dependent: :destroy
end
