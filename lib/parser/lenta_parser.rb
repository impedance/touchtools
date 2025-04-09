require 'net/http'
require 'json'
require 'uri'

class LentaParser
  def initialize
    @user_agent = "Mozilla/5.0 (Android 10; Mobile; rv:122.0) Gecko/122.0 Firefox/122.0"
  end

  def get_product_info(product_url)
    begin
      # Извлекаем ID товара из URL
      product_id = product_url.split('/product/')[1].split('-')[-1]
      
      # Формируем URL для API
      api_url = "https://lenta.com/api/v2/stores/1352/skus/#{product_id}"
      
      # Создаем URI объект
      uri = URI(api_url)
      
      # Создаем HTTP запрос
      request = Net::HTTP::Get.new(uri)
      request['User-Agent'] = "Mozilla/5.0 (Android 10; Mobile; rv:122.0) Gecko/122.0 Firefox/122.0"
      
      # Выполняем запрос
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
      
      # Проверяем успешность запроса
      response.value
      
      # Парсим JSON ответ
      data = JSON.parse(response.body)
      
# Формируем результат
result = {
  название: data["title"],
  рейтинг: data["rates"]["averageRate"],
  всего_оценок: data["rates"]["totalCount"],
  распределение_оценок: {
    "1 звезда" => data["rates"]["scores"]["rate1"],
    "2 звезды" => data["rates"]["scores"]["rate2"],
    "3 звезды" => data["rates"]["scores"]["rate3"],
    "4 звезды" => data["rates"]["scores"]["rate4"],
    "5 звезд" => data["rates"]["scores"]["rate5"]
  },
  отзывы: data["comments"] ? data["comments"].map { |comment| comment["text"] } : [],
  url: product_url
}


result
      
    rescue StandardError => e
      puts "Ошибка при парсинге: #{e.message}"
      {
        ошибка: e.message
      }
    end
  end
end

# Пример использования
if __FILE__ == $0
  parser = LentaParser.new
  product_url = "https://lenta.com/product/shokoladnye-batonchiki-snickers-super-rossiya-80g-580825/"
  result = parser.get_product_info(product_url)
  
  # Выводим результат в читаемом виде
  puts "=== Информация о товаре ==="
  puts "Название: #{result[:название]}"
  puts "Рейтинг: #{result[:рейтинг]}"
  puts "Всего оценок: #{result[:всего_оценок]}"
  puts "\nРаспределение оценок:"
  result[:распределение_оценок].each do |stars, count|
    puts "#{stars}: #{count}"
  end
  puts "\nОтзывы:"
  result[:отзывы].each { |review| puts review } if result[:отзывы]
  puts "\nURL: #{result[:url]}"
end
