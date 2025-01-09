# frozen_string_literal: true

# == Schema Information
#
# Table name: feature_flags
#
#  id         :bigint           not null, primary key
#  comment    :string           default(""), not null
#  name       :string           not null
#  value      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_feature_flags_on_name  (name) UNIQUE
#
FactoryBot.define do
  factory :feature_flag do
    sequence(:name) { |n| "feature_flag_#{n}" }
    value { 'true' }
  end
end
