# frozen_string_literal: true

module HasEmailConfirmation
  extend ActiveSupport::Concern

  included do
    normalizes :email, with: NormalizeEmail
    normalizes :change_email, with: NormalizeEmail

    validates :email,
      presence: true,
      length: { minimum: 3, maximum: 255 },
      email: true

    attr_accessor :skip_email_uniqueness_validation

    validates :email,
      uniqueness: { case_sensitive: false },
      unless: :skip_email_uniqueness_validation
  end

  def confirmed_email?
    email_confirmed_at.present?
  end

  def unconfirmed_email?
    !confirmed_email?
  end

  def confirm_email!(time = nil)
    update!(email_confirmed_at: time || Time.current)
  end

  def unconfirm_email!
    update!(email_confirmed_at: nil)
  end

  def confirmed_change_email?
    change_email_confirmed_at.present?
  end

  def unconfirmed_change_email?
    !confirmed_change_email?
  end

  def confirm_change_email!(time = nil)
    update!(change_email_confirmed_at: time || Time.current)
  end

  def unconfirm_change_email!
    update!(change_email_confirmed_at: nil)
  end

  def revert_change_email!(previous_email, time = nil)
    current_time = Time.current

    update!(
      email: previous_email,
      email_confirmed_at: time || current_time,
      change_email: nil,
      change_email_confirmed_at: nil,
      change_email_reverted_at: time || current_time
    )
  end
end
