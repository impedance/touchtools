class CreateProductMetrics < ActiveRecord::Migration[7.1]
  def change
    create_table :product_metrics do |t|
      t.references :product_source, null: false, foreign_key: true
      t.float :rating
      t.integer :reviews_count
      t.datetime :collected_at, null: false
      t.timestamps
    end
    
    add_index :product_metrics, [:product_source_id, :collected_at]
  end
end