class CreateDummies < ActiveRecord::Migration[7.1]
  def change
    create_table :dummies do |t|
      t.uuid     :uuid
      t.string   :string
      t.integer  :integer
      t.decimal  :decimal
      t.float    :float
      t.date     :date
      t.datetime :datetime

      t.timestamps
    end
  end
end
