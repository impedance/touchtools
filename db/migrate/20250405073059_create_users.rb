class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :telegram_user_id, index: { unique: true }
      t.string :email, index: { unique: true }
      t.string :encrypted_password

      t.timestamps
    end
  end
end