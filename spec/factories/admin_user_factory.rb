# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_users
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
#  index_admin_users_on_email  (email) UNIQUE
#  index_admin_users_on_uuid   (uuid) UNIQUE
#
FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "admin.user.#{n}@test.upper.town" }
    password { 'testpass' }
  end
end
