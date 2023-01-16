# frozen_string_literal: true

# == Schema Information
#
# Table name: servers
#
#  id          :bigint           not null, primary key
#  description :string           default(""), not null
#  info        :text             default(""), not null
#  kind        :string           default(""), not null
#  name        :string           default(""), not null
#  site_url    :string           default(""), not null
#  uuid        :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_servers_on_uuid  (uuid) UNIQUE
#
class Server < ApplicationRecord
  has_many :server_votes, dependent: :destroy
end
