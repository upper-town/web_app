# frozen_string_literal: true

# == Schema Information
#
# Table name: dummies
#
#  id         :bigint           not null, primary key
#  date       :date
#  datetime   :datetime
#  decimal    :decimal(, )
#  float      :float
#  integer    :integer
#  string     :string
#  uuid       :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Dummy < ApplicationRecord
end
