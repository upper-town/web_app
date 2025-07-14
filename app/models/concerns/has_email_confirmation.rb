# frozen_string_literal: true

module HasEmailConfirmation
  extend ActiveSupport::Concern

  included do
    normalizes :email, with: NormalizeEmail

    validates :email, presence: true, length: { minimum: 3, maximum: 255 }, email: true
    validates :email, uniqueness: { case_sensitive: false }
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
end
