# frozen_string_literal: true

class AddUuidToUsers < ActiveRecord::Migration[7.1]
  # rubocop:disable Rails/NotNullColumn
  def change
    add_column :users, :uuid, :uuid, null: false
  end
  # rubocop:enable Rails/NotNullColumn
end
