require 'net/http'
require 'json'
require 'uri'
require 'nokogiri'
require 'logger'

module Parser
  class MagnitParser
    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::WARN
      @user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    end

    def run
      product_url = ARGV.first || 'https://magnit.ru/product/1000233462-file_tsb_okhl_lotok_1_kg_v_lotok_ooo_soyuzptitseprom_5/'
      product_source = OpenStruct.new(url: product_url)
      result = parse(product_source)
      puts result
    end

    def parse(product_source)
      product_url = product_source.url
      begin
        @logger.info "Начало парсинга товара по URL: #{product_url}"

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

        @logger.info "Успешный запрос к URL: #{product_url}"

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
        result = {
          # Основная информация
          наименование: doc.css('div.unit-product-details__name-inner > span.pl-text[itemprop="name"]').text.strip,
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

        formatted_output = format_output(result)
        puts formatted_output
      rescue StandardError => e
        @logger.error "Ошибка при парсинге URL #{product_url}: #{e.message}"
        "Ошибка: #{e.message}"
      end
    end

    def format_output(data)
      name = data[:наименование] || 'нет'
      rating = data[:рейтинг] || 'нет'
      total_reviews = data[:количество_оценок] || 'нет'
      discount_price = data[:цена_со_скидкой]
      regular_price = data[:обычная_цена]
      price = discount_price ? "#{discount_price}р" : 'нет'
      original_price = discount_price && regular_price ? "#{regular_price}р" : 'нет'
      discount_percentage = discount_price && regular_price ? ((regular_price.to_f - discount_price.to_f) / regular_price.to_f * 100).round(2) : 'нет'
      discount = discount_percentage != 'нет' ? "#{discount_percentage}%" : 'нет'
      reviews_count = data[:количество_отзывов] || 'нет'

      [
        "Наименование: #{name}",
        "Рейтинг общий: #{rating}",
        "Количество оценок: #{total_reviews}",
        "Скидка: #{discount}",
        "Цена: #{price}",
        "Цена без скидки: #{original_price}",
        "Количество отзывов: #{reviews_count}"
      ].join("\n")
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
end

if __FILE__ == $0
  parser = Parser::MagnitParser.new
  parser.run
end
