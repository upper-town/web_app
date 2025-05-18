# frozen_string_literal: true

class CreateServerStats < ActiveRecord::Migration[7.1]
  def change
    create_table :server_stats do |t|
      t.string     :period,         null: false
      t.date       :reference_date, null: false
      t.references :game,           null: false, foreign_key: true, index: false
      t.string     :country_code,   null: false
      t.references :server,         null: false, foreign_key: true, index: false

      t.bigint   :vote_count,                 null: false, default: 0
      t.datetime :vote_count_consolidated_at, null: true

      t.bigint   :ranking_number,                 null: true, default: nil
      t.datetime :ranking_number_consolidated_at, null: true

      t.timestamps
    end

    add_index(
      :server_stats,
      [:period, :reference_date, :game_id, :country_code, :server_id],
      unique: true,
      name: "index_server_stats_on_period_reference_app_country_server"
    )
    add_index :server_stats, :server_id
  end
end
