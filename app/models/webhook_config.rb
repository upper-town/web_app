# frozen_string_literal: true

class WebhookConfig < ApplicationRecord
  METHODS = ["POST", "GET", "PUT", "PATCH"]

  belongs_to :source, polymorphic: true

  has_many :events, class_name: "WebhookEvent", dependent: :destroy

  encrypts :secret

  normalizes :event_types, with: ->(list) do
    list.map { |str| str.downcase.delete("^a-z_.*") if str }.compact_blank
  end
  normalizes :secret, with: ->(str) { str.gsub(/[[:space:]]/, "") }
  normalizes :method, with: ->(str) { str.upcase.delete("^A-Z") }

  validates :method, inclusion: { in: METHODS }, presence: true

  def self.enabled
    where(disabled_at: nil)
  end

  def self.disabled
    where.not(disabled_at: nil)
  end

  def self.for(source, event_type)
    enabled.where(source:).filter { |config| config.subscribed?(event_type) }
  end

  def enabled?
    disabled_at.nil?
  end

  def disabled?
    !enabled?
  end

  def subscribed?(event_type)
    event_types.any? { |event_type_pattern| File.fnmatch?(event_type_pattern, event_type) }
  end

  def not_subscribed?(...)
    !subscribed?(...)
  end
end
