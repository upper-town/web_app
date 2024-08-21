# frozen_string_literal: true

module HasEmailConfirmation
  extend ActiveSupport::Concern

  included do
    normalizes :email, with: EmailNormalizer
    normalizes :change_email, with: EmailNormalizer

    validates :email, presence: true, email: true, uniqueness: { case_sensitive: false }
  end

  def confirmed_email?
    email_confirmed_at.present?
  end

  def unconfirmed_email?
    !confirmed_email?
  end

  def confirm_email!
    update!(email_confirmed_at: Time.current)
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

  def confirm_change_email!
    update!(change_email_confirmed_at: Time.current)
  end

  def unconfirm_change_email!
    update!(change_email_confirmed_at: nil)
  end

  def revert_change_email!(previous_email)
    update!(
      email: previous_email,
      email_confirmed_at: Time.current,
      change_email: nil,
      change_email_confirmed_at: nil,
      change_email_reverted_at: Time.current
    )
  end
end
