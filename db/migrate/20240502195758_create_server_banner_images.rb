class CreateServerBannerImages < ActiveRecord::Migration[7.1]
  def change
    create_table :server_banner_images do |t|
      t.references :server, null: false, foreign_key: true

      t.string :content_type, null: false
      t.binary :blob,         null: false
      t.jsonb  :metadata,     null: false, default: {}
      t.bigint :byte_size,    null: false
      t.string :checksum,     null: false

      t.datetime :approved_at, null: true, default: nil

      t.timestamps
    end
  end
end
