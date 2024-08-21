# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_users
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
#  index_admin_users_on_email  (email) UNIQUE
#
class AdminUser < ApplicationRecord
  include FeatureFlagId
  include HasAdminTokens
  include HasEmailConfirmation
  include HasPassword

  has_one :account, class_name: 'AdminAccount', dependent: :destroy

  has_many :sessions, class_name: 'AdminSession', dependent: :destroy
  has_many :tokens, class_name: 'AdminToken', dependent: :destroy

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
end
