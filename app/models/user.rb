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
  include FeatureFlagId
  include HasTokens

  has_one :account, class_name: 'Account', dependent: :destroy

  has_many :sessions, class_name: 'Session', dependent: :destroy
  has_many :tokens, class_name: 'Token', dependent: :destroy

  has_secure_password validations: false

  normalizes :email, with: EmailNormalizer
  normalizes :change_email, with: EmailNormalizer

  validates :email, uniqueness: { case_sensitive: false }, presence: true
  validates :password, length: { minimum: 8 }, allow_blank: true

  validate do |record|
    EmailRecordValidator.new(record).validate
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

  def lock_access!(reason, comment = nil)
    update!(
      locked_reason:  reason,
      locked_comment: comment,
      locked_at:      Time.current
    )
  end

  def unlock_access!
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
