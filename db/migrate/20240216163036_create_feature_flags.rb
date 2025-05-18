# frozen_string_literal: true

class CreateFeatureFlags < ActiveRecord::Migration[7.1]
  def change
    create_table :feature_flags do |t|
      t.string :name,    null: false
      t.string :value,   null: false
      t.string :comment, null: false, default: ""

      t.timestamps
    end

    add_index :feature_flags, :name, unique: true
  end
end
