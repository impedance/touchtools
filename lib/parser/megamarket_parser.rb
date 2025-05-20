require 'net/http'
require 'json'
require 'uri'
require 'nokogiri'
require 'logger'

module Parser
  class MegamarketParser
    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG
      @user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    end

    def run(product_url)
      product_source = OpenStruct.new(url: product_url)
      result = parse(product_source)
      return result
    end

    def parse(product_source)
      product_url = product_source.url
      begin
        # Создаем URI объект
        uri = URI(product_url)

        # Создаем HTTP запрос
        request = Net::HTTP::Get.new(uri)
        request['User-Agent'] = @user_agent
        request['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
        request['Accept-Language'] = 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3'

        # Выполняем запрос с обработкой редиректов
        response = nil
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          response = http.request(request)
          if response.is_a?(Net::HTTPRedirection)
            uri = URI.parse(response['location'])
            request = Net::HTTP::Get.new(uri)
            request['User-Agent'] = @user_agent
            request['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
            request['Accept-Language'] = 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3'
            response = http.request(request)
          end
        end

        # Проверяем успешность запроса
        response.value

        # Парсим HTML
        doc = Nokogiri::HTML(response.body)

        # Получаем данные о товаре
        name = doc.css('h1.pdp-header__title').text.strip
        price = doc.css('.sales-block-offer-price__price-final').text.strip
        rating = doc.css('.pui-rating-display__narrow-text').text.strip
        reviews_count = doc.css('.pui-rating-display__text').text.strip.gsub(/[^0-9]/, '')

        # Формируем результат
        result = {
          наименование: name,
          цена: price,
          рейтинг: rating,
          количество_отзывов: reviews_count
        }

        formatted_output = format_output(result)
        return formatted_output
      rescue StandardError => e
        @logger.error "Ошибка при парсинге URL #{product_url}: #{e.message}"
        @logger.error "Ошибка: #{e.message}"
        return "Ошибка: #{e.message}"
      end
    end

    def format_output(data)
      name = data[:наименование] || 'нет'
      price = data[:цена] || 'нет'
      rating = data[:рейтинг] || 'нет'
      reviews_count = data[:количество_отзывов] || 'нет'

      [
        "Наименование: #{name}",
        "Цена: #{price}",
        "Рейтинг: #{rating}",
        "Количество отзывов: #{reviews_count}"
      ].join("\n")
    end
  end
end

require_relative 'parser_factory'

# Example usage:
if __FILE__ == $0
  url = "https://megamarket.ru/catalog/details/keks-samokat-stolichnyy-270-g-100029219336_13576/"
  result = Parser::ParserFactory.create(url)
  puts "#{result}"
end
