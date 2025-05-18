class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string   :email, null: false
      t.datetime :email_confirmed_at
      t.datetime :email_confirmation_sent_at

      t.string   :password_digest
      t.datetime :password_reset_at
      t.datetime :password_reset_sent_at

      t.integer :sign_in_count,   null: false, default: 0
      t.integer :failed_attempts, null: false, default: 0

      t.string   :change_email
      t.datetime :change_email_confirmed_at
      t.datetime :change_email_confirmation_sent_at
      t.datetime :change_email_reverted_at
      t.datetime :change_email_reversion_sent_at

      t.datetime :locked_at
      t.string   :locked_reason
      t.text     :locked_comment

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
