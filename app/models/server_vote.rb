# frozen_string_literal: true

# == Schema Information
#
# Table name: server_votes
#
#  id         :bigint           not null, primary key
#  metadata   :jsonb            not null
#  uuid       :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  server_id  :bigint           not null
#
# Indexes
#
#  index_server_votes_on_server_id  (server_id)
#  index_server_votes_on_uuid       (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#
class ServerVote < ApplicationRecord
  belongs_to :server
end
