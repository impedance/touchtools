require 'net/http'
require 'json'
require 'uri'
require 'nokogiri'
require 'logger'

module Parser
  class DixyParser
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

        # Получаем название товара и цены
        name = doc.css('h1.detail-card__title').text.strip
        discounted_price = doc.css('.card__price-num').first.text.strip
        regular_price = doc.css('.card__price-crossed').first.text.strip

        # Формируем результат
        result = {
          наименование: name,
          цена_со_скидкой: discounted_price,
          цена_без_скидки: regular_price
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
      discounted_price = data[:цена_со_скидкой] || 'нет'
      regular_price = data[:цена_без_скидки] || 'нет'

      [
        "Наименование: #{name}",
        "Цена со скидкой: #{discounted_price}",
        "Цена без скидки: #{regular_price}"
      ].join("\n")
    end
  end
end

require_relative 'parser_factory'

# Example usage:
if __FILE__ == $0
  url = "https://dostavka.dixy.ru/catalog/myaso-ptitsa/svinina/318259/"
  result = Parser::ParserFactory.create(url)
  puts "#{result}"
end
