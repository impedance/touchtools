require 'net/http'
require 'json'
require 'uri'
require 'logger'
require 'nokogiri'

module Parser
  class LentaParser
    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::WARN
      @store_id = 1352
      @user_agents = [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:89.0) Gecko/20100101 Firefox/89.0",
        "Mozilla/5.0 (iPad; CPU OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1 Mobile/15E148 Safari/604.1"
      ]
      @retry_attempts = 3
    end

    def run(product_url)
      result = get_product_info(product_url)
      puts result
    end

    def get_product_info(product_source)
      product_url = product_source.is_a?(String) ? product_source : product_source.url
      attempt = 0
      begin
        attempt += 1
        @logger.info "Начало парсинга товара по URL: #{product_url}, попытка #{attempt}"

        # Извлекаем ID товара из URL
        product_id = product_url.split('/').last

        raise "Неверный формат URL: #{product_url}" unless product_id

        @logger.info "Извлечённый ID товара: #{product_id}"

        # Fetch the product page
        uri = URI(product_url)
        request = Net::HTTP::Get.new(uri)
        request['User-Agent'] = @user_agents.sample

        sleep(1) # Add a delay to avoid rate limiting

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        response.value
        response.body.force_encoding('UTF-8')
        html_content = response.body

        # Parse the HTML content
        data = parse_html(html_content)

        @logger.info "Парсинг завершён успешно: #{data['title']}"

        formatted_output = format_output(data)
        puts formatted_output

      rescue StandardError => e
        @logger.error "Ошибка при парсинге URL #{product_url}: #{e.message}"
        if attempt < @retry_attempts
          @logger.info "Повторная попытка через 5 секунд..."
          sleep(5)
          retry
        else
          @logger.error "Превышено количество попыток. Парсинг не удался."
          return "Ошибка: #{e.message}"
        end
      end
    end

    def parse_html(html_content)
      doc = Nokogiri::HTML(html_content)

      title = doc.at_css('h1.sku-page-title').text.strip rescue nil
      regular_price = doc.at_css('div.sku-price-block__price-old span.sku-price-block__price').text.strip.gsub(' ', '').gsub('₽', '').to_f rescue nil
      discount_price = doc.at_css('div.sku-price-block__price span.sku-price-block__price').text.strip.gsub(' ', '').gsub('₽', '').to_f rescue nil
      rating = doc.at_css('span.sku-page-header__rating-rate').text.strip.to_f rescue nil
      total_reviews = doc.at_css('span.sku-page-header__rating-count').text.strip.to_i rescue nil
      reviews_count = total_reviews # Assuming total_reviews is the same as reviews_count

      {
        'title' => title,
        'regular_price' => regular_price,
        'discount_price' => discount_price,
        'rating' => rating,
        'total_reviews' => total_reviews,
        'reviews_count' => reviews_count
      }
    end

    def format_output(data)
      rating = data['rating'] || 'нет'
      total_reviews = data['total_reviews'] || 'нет'
      discount_price = data['discount_price']
      regular_price = data['regular_price']
      price = discount_price ? "#{discount_price}р" : 'нет'
      original_price = discount_price && regular_price ? "#{regular_price}р" : 'нет'
      discount_percentage = discount_price && regular_price ? ((regular_price.to_f - discount_price.to_f) / regular_price.to_f * 100).round(2) : 'нет'
      discount = discount_percentage != 'нет' ? "#{discount_percentage}%" : 'нет'
      reviews_count = data['reviews_count'] || 'нет'

      [
        "Рейтинг общий: #{rating}",
        "Количество оценок: #{total_reviews}",
        "Скидка: #{discount}",
        "Цена: #{price}",
        "Цена без скидки: #{original_price}",
        "Количество отзывов: #{reviews_count}"
      ].join("\n")
    end

    if __FILE__ == $0
      product_url = 'https://lenta.com/product/shashlyk-lenta-fresh-sp-iz-svinogo-okoroka-v-kefire-polufabrikat-ohlazhdennyjj-068416/'
      parser = Parser::LentaParser.new
      parser.run(product_url)
    end
  end
end
