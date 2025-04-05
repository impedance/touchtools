class ProductMetric < ApplicationRecord
  belongs_to :product_source
  
  scope :recent, ->(days=30) { where(collected_at: days.days.ago..Time.current) }
end