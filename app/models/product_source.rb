class ProductSource < ApplicationRecord
  belongs_to :user
  has_many :product_metrics, dependent: :destroy
  
  enum provider_type: { dixy: 'dixy', lenta: 'lenta', magnit: 'magnit' }
  enum status: { active: 'active', parsing: 'parsing', error: 'error' }
  
  validates :url, presence: true
  validates :provider_type, presence: true
end