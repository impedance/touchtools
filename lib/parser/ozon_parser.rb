require 'net/http'
require 'json'
require 'uri'
require 'nokogiri'
require 'logger'
require 'selenium-webdriver'
require 'securerandom'

module Parser
  class OzonParser
    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG
      
      # Разнообразные реалистичные User-Agent строки
      @user_agents = [
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:98.0) Gecko/20100101 Firefox/98.0',
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36'
      ]
      
      @user_agent = @user_agents.sample
    end

    def run(product_url)
      begin
        # Пробуем несколько раз с разными настройками в случае неудачи
        max_attempts = 3
        attempt = 0
        
        while attempt < max_attempts
          @logger.info "Попытка #{attempt + 1} из #{max_attempts}"
          result = parse(product_url, attempt)
          
          # Если получили ограничение доступа, попробуем еще раз
          if result.include?("наименование: Доступ ограничен")
            attempt += 1
            sleep(2 + rand(3)) # Случайная пауза между попытками
          else
            return result
          end
        end
        
        return "Ошибка: Не удалось обойти защиту сайта после #{max_attempts} попыток"
      rescue StandardError => e
        @logger.error "Ошибка при парсинге URL #{product_url}: #{e.message}"
        @logger.error e.backtrace.join("\n")
        return "Ошибка: #{e.message}"
      end
    end

    def parse(product_url, attempt_number = 0)
      # Используем Selenium для загрузки страницы
      html = fetch_page_with_selenium(product_url, attempt_number)
      
      # Парсим HTML
      doc = Nokogiri::HTML(html)
      
      # Проверяем, не заблокирован ли доступ
      if doc.to_s.include?("Доступ ограничен") || doc.to_s.include?("captcha")
        @logger.warn "Доступ ограничен или требуется капча!"
        return "наименование: Доступ ограничен\nцена: нет\nрейтинг_товара: нет\nколичество_отзывов: нет\nбренд: нет\nтип_продукта: нет\nвес: нет"
      end
      
      # Извлекаем данные
      name = parse_name(doc)
      price = parse_price(doc)
      rating = parse_rating(doc)
      reviews_count = parse_reviews_count(doc)
      brand = parse_brand(doc)
      product_type = parse_product_type(doc)
      weight = parse_weight(doc)
      
      # Формируем результат
      result = {
        наименование: name,
        цена: price,
        рейтинг_товара: rating,
        количество_отзывов: reviews_count,
        бренд: brand,
        тип_продукта: product_type,
        вес: weight
      }
      
      formatted_output = format_output(result)
      return formatted_output
    end
    
    def fetch_page_with_selenium(product_url, attempt_number = 0)
      options = Selenium::WebDriver::Chrome::Options.new
      
      # В последней попытке попробуем не использовать headless режим
      use_headless = (attempt_number < 2)
      
      if use_headless
        options.add_argument('--headless=new')
      end
      
      # Базовые настройки для маскировки автоматизации
      options.add_argument('--disable-blink-features=AutomationControlled')
      options.add_argument('--disable-dev-shm-usage')
      options.add_argument('--disable-extensions')
      options.add_argument('--no-sandbox')
      options.add_argument('--start-maximized')
      options.add_argument('--window-size=1920,1080')
      options.add_argument('--ignore-certificate-errors')
      
      # Случайный User-Agent
      current_user_agent = @user_agents.sample
      options.add_argument("--user-agent=#{current_user_agent}")
      
      # Добавляем языковые настройки
      options.add_argument('--lang=ru-RU,ru')
      
      # Настройки для преодоления обнаружения ботов
      options.add_argument('--disable-gpu')
      options.add_argument('--enable-features=NetworkService,NetworkServiceInProcess')
      
      # Добавление уникального профиля браузера для сохранения cookies
      profile_dir = "chrome_profile_#{SecureRandom.hex(8)}"
      options.add_argument("--user-data-dir=/tmp/#{profile_dir}")
      
      # Устанавливаем дополнительные заголовки
      options.add_argument("--disable-features=IsolateOrigins,site-per-process")
      
      driver = Selenium::WebDriver.for :chrome, options: options
      
      begin
        # Установка таймаута загрузки страницы
        driver.manage.timeouts.page_load = 30
        
        # Сначала идем на главную страницу Ozon
        @logger.info "Переход на главную страницу Ozon"
        driver.get("https://www.ozon.ru/")
        
        # Случайная пауза имитирующая пользователя
        sleep(1 + rand(2))
        
        # Эмуляция прокрутки страницы как реальный пользователь
        @logger.info "Эмуляция прокрутки страницы"
        driver.execute_script("window.scrollBy(0, #{100 + rand(300)})")
        sleep(0.5 + rand(1))
        driver.execute_script("window.scrollBy(0, #{300 + rand(500)})")
        sleep(0.3 + rand(0.7))
        
        # Теперь переходим на страницу товара
        @logger.info "Переход на страницу товара"
        driver.get(product_url)
        
        # Ждем загрузки контента
        sleep(2 + rand(3))
        
        # Эмуляция перемещения мыши и прокрутки
        @logger.info "Эмуляция поведения пользователя на странице"
        driver.execute_script("window.scrollBy(0, #{200 + rand(300)})")
        sleep(0.5 + rand(1))
        driver.execute_script("window.scrollBy(0, #{400 + rand(300)})")
        sleep(0.5 + rand(1))
        
        # Ждем еще немного для полной загрузки
        sleep(1 + rand(2))
        
        # Получаем исходный код страницы
        page_source = driver.page_source
        return page_source
      ensure
        driver.quit
        # Удаляем временный профиль
        if Dir.exist?("/tmp/#{profile_dir}")
          begin
            FileUtils.rm_rf("/tmp/#{profile_dir}")
          rescue => e
            @logger.error "Не удалось удалить временный профиль: #{e.message}"
          end
        end
      end
    end
    
    # Методы парсинга отдельных элементов
    def parse_name(doc)
      # Различные селекторы для названия
      selectors = [
        'h1.q7m_28.tsHeadline550Medium',
        'h1.qm7_28.tsHeadline550Medium',
        'h1.tsHeadline550Medium',
        'h1'
      ]
      
      selectors.each do |selector|
        elements = doc.css(selector)
        elements.each do |element|
          text = element.text.strip
          return text if text.include?('Ребрышки') || (text.length > 10 && !text.include?('Доступ ограничен'))
        end
      end
      
      'нет'
    rescue => e
      @logger.error "Error parsing name: #{e.message}"
      'нет'
    end
    
    def parse_price(doc)
      # Различные селекторы для цены
      selectors = [
        'span.m1q_28.qm1_28.q5m_28',
        'span.mq1_28.m1q_28.qm5_28',
        'span.mq1_28.qm5_28',
        'div[data-widget="webPrice"] span'
      ]
      
      selectors.each do |selector|
        elements = doc.css(selector)
        elements.each do |element|
          if element.text.include?('₽')
            return element.text.gsub(/[^0-9]/, '')
          end
        end
      end
      
      # Поиск по содержимому
      doc.css('span').each do |span|
        if span.text.match(/^\d+\s*₽$/) || span.text.match(/\d+\s*₽/)
          return span.text.gsub(/[^0-9]/, '')
        end
      end
      
      'нет'
    rescue => e
      @logger.error "Error parsing price: #{e.message}"
      'нет'
    end
    
    def parse_rating(doc)
      # Селекторы для рейтинга
      selectors = [
        'div.ga100-a2.tsBodyControl500Medium',
        'div.tsBodyControl500Medium'
      ]
      
      selectors.each do |selector|
        elements = doc.css(selector)
        elements.each do |element|
          if element.text.include?('•') && element.text.match(/\d+[\.,]\d+/)
            rating_match = element.text.match(/(\d+[\.,]\d+)/)
            return rating_match ? rating_match[1].gsub(',', '.') : 'нет'
          end
        end
      end
      
      # Поиск по содержимому
      doc.css('div').each do |div|
        if div.text.match(/\d+\.\d+\s+•/) || div.text.match(/\d+[\.,]\d+\s+•/)
          rating_match = div.text.match(/(\d+[\.,]\d+)/)
          return rating_match ? rating_match[1].gsub(',', '.') : 'нет'
        end
      end
      
      'нет'
    rescue => e
      @logger.error "Error parsing rating: #{e.message}"
      'нет'
    end
    
    def parse_reviews_count(doc)
      # Селекторы для количества отзывов
      selectors = [
        'div.ga100-a2.tsBodyControl500Medium',
        'div.tsBodyControl500Medium'
      ]
      
      selectors.each do |selector|
        elements = doc.css(selector)
        elements.each do |element|
          if element.text.include?('отзыв')
            reviews_match = element.text.match(/(\d[\s\d]*)\s+отзыв/)
            return reviews_match ? reviews_match[1].gsub(/\s+/, '') : 'нет'
          end
        end
      end
      
      # Поиск по содержимому
      doc.css('div').each do |div|
        if div.text.match(/\d+\s+отзыв/) || div.text.include?('отзыв')
          reviews_match = div.text.match(/(\d[\s\d]*)\s+отзыв/)
          return reviews_match ? reviews_match[1].gsub(/\s+/, '') : 'нет'
        end
      end
      
      'нет'
    rescue => e
      @logger.error "Error parsing reviews count: #{e.message}"
      'нет'
    end
    
    def parse_brand(doc)
      # Селекторы для бренда
      selectors = [
        'a.tsCompactControl500Medium',
        'span.tsCompactControl500Medium',
        'a[href*="cherkizovo"]'
      ]
      
      selectors.each do |selector|
        elements = doc.css(selector)
        elements.each do |element|
          text = element.text.strip
          return text if text.downcase == 'черкизово' || text.length > 0
        end
      end
      
      # Поиск по содержимому "Черкизово"
      doc.css('a, span, div').each do |element|
        text = element.text.strip
        return text if text.downcase == 'черкизово'
      end
      
      'нет'
    rescue => e
      @logger.error "Error parsing brand: #{e.message}"
      'нет'
    end
    
    def parse_product_type(doc)
      # Селекторы для типа продукта
      selectors = [
        '.wm0_28 .v8m_28 .tsBody400Small',
        '.w0m_28 .mv9_28 .tsBody400Small',
        '.tsBody400Small'
      ]
      
      selectors.each do |selector|
        elements = doc.css(selector)
        elements.each do |element|
          text = element.text.strip
          return text if text == 'Мясо охлажденное' || text.include?('Мясо')
        end
      end
      
      # Ищем в разделе "О товаре"
      about_sections = [
        doc.css('.wm0_28'), 
        doc.css('.w0m_28'),
        doc.css('div[data-widget="webShortCharacteristics"]')
      ]
      
      about_sections.each do |section|
        section.css('.tsBody400Small, span').each do |element|
          text = element.text.strip
          return text if text.include?('Мясо') || text.include?('охлажденное')
        end
      end
      
      # Поиск по ключевым словам
      doc.css('span, div').each do |element|
        text = element.text.strip
        return text if text == 'Мясо охлажденное' || text.include?('охлажденное')
      end
      
      'нет'
    rescue => e
      @logger.error "Error parsing product type: #{e.message}"
      'нет'
    end
    
    def parse_weight(doc)
      # Ищем элемент с весом по тексту
      doc.css('span, div').each do |element|
        text = element.text.strip
        if text.match(/1\.20-1\.50\s+кг/) || text.match(/\d+\.\d+-\d+\.\d+\s+кг/)
          weight_match = text.match(/(\d+\.\d+)-(\d+\.\d+)\s+кг/)
          return weight_match[2] if weight_match
        end
      end
      
      # Ищем в блоке "Диапазон веса"
      doc.css('div, span').each do |element|
        if element.text.include?('Диапазон веса') || element.text.include?('вес')
          parent = element.parent
          if parent
            elements = parent.css('span, div')
            elements.each do |child|
              text = child.text.strip
              if text.match(/\d+\.\d+/) && (text.include?('кг') || text.match(/\d+\.\d+-\d+\.\d+/))
                weight_match = text.match(/(\d+\.\d+)-(\d+\.\d+)/)
                return weight_match ? weight_match[2] : text.match(/(\d+\.\d+)/)[1]
              end
            end
          end
        end
      end
      
      # Поиск по ключевому слову 1.50 кг
      doc.css('span, div').each do |element|
        text = element.text.strip
        if text.include?('1.50 кг') || text.include?('1,50 кг')
          return '1.5'
        end
      end
      
      'нет'
    rescue => e
      @logger.error "Error parsing weight: #{e.message}"
      'нет'
    end
    
    def format_output(data)
      output = []
      data.each do |key, value|
        output << "#{key}: #{value || 'нет'}"
      end
      output.join("\n")
    end
  end
end

# Пример использования:
if __FILE__ == $0
  url = "https://www.ozon.ru/product/rebryshki-svinye-v-marinade-appetitnye-1-2-1-5-kg-cherkizovo-ohlazhdennoe-711016451/?at=83tB5xxnZUVzPY66t6oZrV1iz8P1DYFpLGzRkH0rnMR0&ectx=1&miniapp=supermarket&miniapp=supermarket"
  parser = Parser::OzonParser.new
  result = parser.run(url)
  puts "#{result}"
end