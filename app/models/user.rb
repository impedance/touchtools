class User < ApplicationRecord
  devise :database_authenticatable, 
         :recoverable, 
         :rememberable, 
         :validatable

  # Убедитесь что эти строки соответствуют вашей исходной структуре
  has_many :product_sources, dependent: :destroy
  has_many :imports, dependent: :destroy

  validates :telegram_user_id, uniqueness: true, allow_nil: true
  validates :email, uniqueness: true
end