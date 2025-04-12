require 'net/http'
require 'json'
require 'uri'
require 'logger'

module Parser
  class LentaParser
    def initialize
      @logger = Logger.new(STDOUT)
      @store_id = 1352
      @user_agent = "Mozilla/5.0 (Android 10; Mobile; rv:122.0) Gecko/122.0 Firefox/122.0"
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

        # Парсим JSON ответ
        data = JSON.parse(response.body)

        @logger.debug "Полученные данные от API: #{data}"

        # Извлекаем необходимые поля
        title = data['title']
        rating = data.dig('rates', 'averageRate') || 0
        total_reviews = data.dig('rates', 'totalCount') || 0
        review_distribution = {
          '1 звезда' => data.dig('rates', 'scores', 'rate1') || 0,
          '2 звезды' => data.dig('rates', 'scores', 'rate2') || 0,
          '3 звезды' => data.dig('rates', 'scores', 'rate3') || 0,
          '4 звезды' => data.dig('rates', 'scores', 'rate4') || 0,
          '5 звезд' => data.dig('rates', 'scores', 'rate5') || 0
        }
        reviews = data['comments'] ? data['comments'].map { |comment| comment['text'] } : []

        @logger.info "Парсинг завершён успешно: #{title}"

        {
          название: title,
          рейтинг: rating,
          всего_оценок: total_reviews,
          распределение_оценок: review_distribution,
          отзывы: reviews,
          url: product_url
        }

      rescue StandardError => e
        @logger.error "Ошибка при парсинге URL #{product_url}: #{e.message}"
        {
          ошибка: e.message
        }
      end
    end
  end
end
