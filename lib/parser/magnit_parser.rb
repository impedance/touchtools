require 'net/http'
require 'json'
require 'uri'
require 'nokogiri'

class MagnitParser
  def initialize
    @user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
  end

  def get_product_info(product_url)
    begin
      # Создаем URI объект
      uri = URI(product_url)
      
      # Создаем HTTP запрос
      request = Net::HTTP::Get.new(uri)
      request['User-Agent'] = @user_agent
      request['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      request['Accept-Language'] = 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3'
      
      # Выполняем запрос
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
      
      # Проверяем успешность запроса
      response.value
      
      # Парсим HTML
      doc = Nokogiri::HTML(response.body)
      
      # Получаем цены и скидку
      price_section = doc.css('section[data-v-ea40eff3]')
      current_price = price_section.css('.product-details-price__current span').text.strip
      old_price = price_section.css('.product-details-price__old span').text.strip
      discount = price_section.css('.pl-label_discount .pl-label__content').text.strip
      
      # Получаем рейтинг и отзывы
      rating_section = doc.css('.product-rating')
      rating = rating_section.css('.product-rating-score').text.strip
      rating_info = rating_section.css('.product-rating-count').text.strip
      # Извлекаем количество оценок и отзывов
      ratings_count = rating_info.split('·')[0].gsub(/[^\d]/, '')
      reviews_count = rating_info.split('·')[1].gsub(/[^\d]/, '')
      
      # Формируем результат
      {
        # Основная информация
        название: doc.css('h1.product-card__title').text.strip,
        бренд: doc.css('.product-card__brand').text.strip,
        описание: doc.css('.product-card__description').text.strip,
        
        # Цены
        обычная_цена: old_price.gsub(/[^\d,.]/, '').gsub(',', '.').to_f,
        цена_со_скидкой: current_price.gsub(/[^\d,.]/, '').gsub(',', '.').to_f,
        скидка: discount.gsub(/[^\d]/, ''),
        
        # Рейтинг и отзывы
        рейтинг: rating.to_f,
        количество_оценок: ratings_count.to_i,
        количество_отзывов: reviews_count.to_i,
        
        # Характеристики
        характеристики: extract_characteristics(doc),
        
        # Категории
        категории: {
          основная: doc.css('.breadcrumbs__item').last&.text&.strip,
          подкатегория: doc.css('.breadcrumbs__item')[-2]&.text&.strip
        },
        
        # Наличие
        наличие: doc.css('.product-card__availability').text.strip,
        
        # Изображения
        изображения: doc.css('.product-card__gallery img').map { |img| img['src'] }
      }
      
    rescue StandardError => e
      puts "Ошибка при парсинге: #{e.message}"
      {
        ошибка: e.message
      }
    end
  end

  private

  def extract_characteristics(doc)
    characteristics = {}
    doc.css('.product-card__characteristics tr').each do |row|
      key = row.css('td').first&.text&.strip
      value = row.css('td').last&.text&.strip
      characteristics[key] = value if key && value
    end
    characteristics
  end
end

# Пример использования
if __FILE__ == $0
  parser = MagnitParser.new
  product_url = "https://magnit.ru/product/9072651204-luk_repchatyy?shopCode=992301&shopType=6"
  result = parser.get_product_info(product_url)
  
  # Выводим результат в читаемом виде
  puts "=== Информация о товаре ==="
  puts "Название: #{result[:название]}"
  puts "Бренд: #{result[:бренд]}"
  puts "Описание: #{result[:описание]}"
  
  puts "\n=== Цены ==="
  puts "Обычная цена: #{result[:обычная_цена]} ₽"
  puts "Цена со скидкой: #{result[:цена_со_скидкой]} ₽" if result[:цена_со_скидкой] > 0
  puts "Скидка: #{result[:скидка]}%" if result[:скидка]
  
  puts "\n=== Рейтинг и отзывы ==="
  puts "Рейтинг: #{result[:рейтинг]}"
  puts "Количество оценок: #{result[:количество_оценок]}"
  puts "Количество отзывов: #{result[:количество_отзывов]}"
  
  puts "\n=== Характеристики ==="
  result[:характеристики].each do |key, value|
    puts "#{key}: #{value}"
  end
  
  puts "\n=== Категории ==="
  puts "Категория: #{result[:категории][:основная]}"
  puts "Подкатегория: #{result[:категории][:подкатегория]}"
  
  puts "\n=== Наличие ==="
  puts "Наличие: #{result[:наличие]}"
  
  puts "\n=== Изображения ==="
  result[:изображения].each_with_index do |img, index|
    puts "Изображение #{index + 1}: #{img}"
  end
end 