# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                                :bigint           not null, primary key
#  change_email                      :string
#  change_email_confirmation_sent_at :datetime
#  change_email_confirmed_at         :datetime
#  change_email_reversion_sent_at    :datetime
#  change_email_reverted_at          :datetime
#  email                             :string           not null
#  email_confirmation_sent_at        :datetime
#  email_confirmed_at                :datetime
#  failed_attempts                   :integer          default(0), not null
#  locked_at                         :datetime
#  locked_comment                    :text
#  locked_reason                     :string
#  password_digest                   :string
#  password_reset_at                 :datetime
#  password_reset_sent_at            :datetime
#  sign_in_count                     :integer          default(0), not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  TOKEN_EXPIRATION = 1.hour
  TOKEN_LENGTH     = 24

  include FeatureFlagIdModel

  has_many :active_sessions, class_name: 'UserActiveSession', dependent: :destroy
  has_many :tokens, class_name: 'UserToken', dependent: :destroy
  has_one :account, class_name: 'UserAccount', dependent: :destroy

  has_secure_password validations: false

  normalizes :email, with: EmailNormalizer
  normalizes :change_email, with: EmailNormalizer

  validates :email, uniqueness: { case_sensitive: false }, presence: true
  validates :password, length: { minimum: 8 }, allow_blank: true

  validate do |record|
    EmailRecordValidator.new(record).validate
  end

  def self.find_by_token(purpose, token)
    return if purpose.blank? || token.blank?

    # TODO: test this
    joins(:tokens)
      .where(tokens: { purpose: purpose, token: token })
      .where('tokens.expires_at > ?', Time.current)
      .order(created_at: :desc)
      .first
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
