class CreateServers < ActiveRecord::Migration[7.1]
  def change
    create_table :servers do |t|
      t.uuid   :uuid,        null: false
      t.string :name,        null: false, default: ''
      t.string :description, null: false, default: ''
      t.string :site_url,    null: false, default: ''
      t.string :kind,        null: false, default: ''

      t.timestamps
    end
  end
end
