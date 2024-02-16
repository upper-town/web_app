# frozen_string_literal: true

module Auth
  module AuthenticationModel
    TOKEN_EXPIRATION = 1.hour
    TOKEN_LENGTH     = 48

    extend ActiveSupport::Concern

    included do
      has_secure_password validations: false

      normalizes :email, with: EmailNormalizer
      normalizes :unconfirmed_email, with: EmailNormalizer

      validates :email, uniqueness: { case_sensitive: false }, presence: true
      validates :unconfirmed_email, uniqueness: { case_sensitive: false }, allow_blank: true
      validates :password, length: { minimum: 8 }, allow_blank: true

      validate do |record|
        EmailRecordValidator.new(record).validate
      end
    end

    class_methods do
      def find_by_token(purpose, value)
        return if purpose.blank? || value.blank?

        # TODO: test this
        joins(:tokens)
          .where(tokens: { purpose: purpose, value: value })
          .where('tokens.expires_at > ?', Time.current)
          .order(created_at: :desc)
          .first
      end
    end

    def regenerate_token!(purpose, expires_in = nil)
      expires_in ||= TOKEN_EXPIRATION

      token = tokens.create!(
        purpose: purpose,
        value: SecureRandom.base58(TOKEN_LENGTH),
        expires_at: expires_in.from_now,
      )

      token.value
    end

    def current_token(purpose)
      tokens
        .where(purpose: purpose)
        .order(created_at: :desc)
        .first&.value
    end

    def confirmed?
      confirmed_at.present?
    end

    def unconfirmed?
      !confirmed?
    end

    def confirm!
      update!(
        email:             unconfirmed_email.presence || email.presence,
        unconfirmed_email: nil,
        confirmed_at:      Time.current,
      )
    end

    def unconfirm!(unconfirmed_email = nil)
      update!(
        unconfirmed_email: unconfirmed_email.presence || email.presence,
        confirmed_at:      nil,
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
