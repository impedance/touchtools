class CreateProductSources < ActiveRecord::Migration[7.1]
  def change
    create_table :product_sources do |t|
      t.references :user, null: false, foreign_key: true
      t.string :url, null: false
      t.string :provider_type, null: false
      t.string :name
      t.string :status, default: 'active'
      t.datetime :last_parsed_at
      t.text :error_message
      t.timestamps
    end
  end
end
