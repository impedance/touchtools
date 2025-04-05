# app/models/user.rb
class User < ApplicationRecord
  has_many :product_sources, dependent: :destroy
  has_many :product_metrics, through: :product_sources
  
  validates :telegram_user_id, uniqueness: true
  
  has_secure_password
end