class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.string :slug,        null: false
      t.string :name,        null: false
      t.string :site_url,    null: false, default: ''
      t.string :description, null: false, default: ''
      t.text   :info,        null: false, default: ''

      t.timestamps
    end

    add_index :games, :slug, unique: true
    add_index :games, :name, unique: true
  end
end
