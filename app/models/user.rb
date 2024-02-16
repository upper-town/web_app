# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmed_at           :datetime
#  email                  :string           not null
#  failed_attempts        :integer          default(0), not null
#  locked_at              :datetime
#  locked_comment         :text
#  locked_reason          :string
#  password_digest        :string
#  password_reset_at      :datetime
#  password_reset_sent_at :datetime
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  uuid                   :uuid             not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#  index_users_on_uuid   (uuid) UNIQUE
#
class User < ApplicationRecord
  include Auth::AuthenticationModel
  include FeatureFlagIdModel

  has_many :active_sessions, class_name: 'UserActiveSession', dependent: :destroy
  has_many :tokens, class_name: 'UserToken', dependent: :destroy
  has_one :account, class_name: 'UserAccount', dependent: :destroy
end
