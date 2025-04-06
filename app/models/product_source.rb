class ProductSource < ApplicationRecord
  belongs_to :user
  has_many :product_metrics, dependent: :destroy

  enum status: { active: 'active', parsing: 'parsing', error: 'error' }

  validates :url, presence: true, format: { 
    with: URI::DEFAULT_PARSER.make_regexp,
    message: 'должен быть валидным URL'
  }

  before_validation :detect_provider
  after_create :schedule_initial_parsing

  scope :by_provider, ->(provider) { provider.present? ? where(provider_type: provider) : all }
  scope :search_by_name, ->(query) { where("LOWER(name) LIKE LOWER(?)", "%#{query}%") }

  private

  def detect_provider
    return if url.blank?

    begin
      uri = URI.parse(url.downcase)
      host = uri.host.gsub('www.', '')

      self.provider_type = case host
        when 'lenta.com' then 'lenta'
        when 'magnit.ru' then 'magnit'
        when 'dostavka.dixy.ru' then 'dixy'
        when 'perekrestok.ru' then 'perekrestok'
        else 'unknown'
      end

      if provider_type == 'unknown'
        errors.add(:url, 'не поддерживаемый магазин')
      end
    rescue URI::InvalidURIError
      errors.add(:url, 'некорректный формат URL')
    end
  end

  def schedule_initial_parsing
    # Будем использовать позже для запуска парсера
    update(status: :parsing)
  end
end
