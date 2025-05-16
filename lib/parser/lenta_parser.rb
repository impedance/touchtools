require 'net/http'
require 'json'
require 'uri'
require 'logger'

module Parser
  class LentaParser
    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::WARN
      @store_id = 1352
      @user_agent = "Mozilla/5.0 (Android 10; Mobile; rv:122.0) Gecko/122.0 Firefox/122.0"
    end

    def run
      product_url = ARGV.first || 'https://lenta.com/product/svinina-slovo-myasnika-lopatka-bk-ohl-rossiya-800g-472961/'
      result = get_product_info(product_url)
      puts result
    end

def get_product_info(product_source)
  product_url = product_source.is_a?(String) ? product_source : product_source.url
  begin
    @logger.info "Начало парсинга товара по URL: #{product_url}"

    # Извлекаем ID товара из URL
    product_id = product_url.split('/product/')[1].split('-').last

    raise "Неверный формат URL: #{product_url}" unless product_id

    @logger.info "Извлечённый ID товара: #{product_id}"

    # Формируем URL для API
    api_url = "https://lenta.com/api/v2/stores/#{@store_id}/skus/#{product_id}"

    # Создаем URI объект
    uri = URI(api_url)

    # Создаем HTTP запрос
    request = Net::HTTP::Get.new(uri)
    request['User-Agent'] = @user_agent

    # Выполняем запрос
response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end

# Проверяем успешность запроса
response.value

@logger.info "Успешный запрос к API: #{api_url}"

# Устанавливаем кодировку ответа в UTF-8
response.body.force_encoding('UTF-8')

# Выводим тело ответа в консоль для отладки
puts "Тело ответа от API: #{response.body}"

# Парсим JSON ответ
data = JSON.parse(response.body)

@logger.debug "Полученные данные от API: #{data}"

# Выводим распарсенные данные в консоль для отладки
puts "Распарсенные данные от API: #{data}"

        # Извлекаем необходимые поля
        title = data['title']
        рейтинг = data.dig('rates', 'averageRate') || 0
        всего_оценок = data.dig('rates', 'totalCount') || 0
        распределение_оценок = {
          '1 звезда' => data.dig('rates', 'scores', 'rate1') || 0,
          '2 звезды' => data.dig('rates', 'scores', 'rate2') || 0,
          '3 звезды' => data.dig('rates', 'scores', 'rate3') || 0,
          '4 звезды' => data.dig('rates', 'scores', 'rate4') || 0,
          '5 звезд' => data.dig('rates', 'scores', 'rate5') || 0
        }
        отзывы = data['comments'] ? data['comments'].map { |comment| comment['text'] } : []

        @logger.info "Парсинг завершён успешно: #{title}"

        {
          название: title,
          рейтинг: рейтинг,
          всего_оценок: всего_оценок,
          распределение_оценок: распределение_оценок,
          отзывы: отзывы,
          url: product_url
        }

      rescue StandardError => e
        @logger.error "Ошибка при парсинге URL #{product_url}: #{e.message}"
        {
          ошибка: e.message
        }
      end
    end

if __FILE__ == $0
  parser = Parser::LentaParser.new
  parser.run
end
  end
end
