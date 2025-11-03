# frozen_string_literal: true

class ServerVote < ApplicationRecord
  belongs_to :server
  belongs_to :game
  belongs_to :account, optional: true

  normalizes :reference, with: ->(str) { str.blank? ? nil : str.strip }

  validate :server_available

  private

  def server_available
    if server.archived?
      errors.add(:server, "cannot be archived")
    elsif server.marked_for_deletion?
      errors.add(:server, "cannot be marked_for_deletion")
    end
  end
end
