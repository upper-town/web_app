# frozen_string_literal: true

module Auth
  module AuthenticationModel
    TOKEN_EXPIRATION = 1.hour
    TOKEN_LENGTH     = 24

    extend ActiveSupport::Concern

    included do
      has_secure_password validations: false

      normalizes :email, with: EmailNormalizer
      normalizes :change_email, with: EmailNormalizer

      validates :email, uniqueness: { case_sensitive: false }, presence: true
      validates :password, length: { minimum: 8 }, allow_blank: true

      validate do |record|
        EmailRecordValidator.new(record).validate
      end
    end

    class_methods do
      def find_by_token(purpose, token)
        return if purpose.blank? || token.blank?

        # TODO: test this
        joins(:tokens)
          .where(tokens: { purpose: purpose, token: token })
          .where('tokens.expires_at > ?', Time.current)
          .order(created_at: :desc)
          .first
      end
    end

    def regenerate_token!(purpose, expires_in = nil, data = {})
      expires_in ||= TOKEN_EXPIRATION

      token = tokens.create!(
        purpose: purpose,
        token: SecureRandom.base58(TOKEN_LENGTH),
        expires_at: expires_in.from_now,
        data: data
      )

      token.token
    end

    def current_token(purpose)
      tokens
        .where(purpose: purpose)
        .order(created_at: :desc)
        .first&.token
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

    def locked?
      locked_at.present?
    end

    def unlocked?
      !locked?
    end

    def lock!(reason, comment = nil)
      update!(
        locked_reason:  reason,
        locked_comment: comment,
        locked_at:      Time.current
      )
    end

    def unlock!
      update!(
        locked_reason:  nil,
        locked_comment: nil,
        locked_at:      nil,
      )
    end

    def reset_password!(password)
      update!(
        password:          password,
        password_reset_at: Time.current
      )
    end
  end
end
