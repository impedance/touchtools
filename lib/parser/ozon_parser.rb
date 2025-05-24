require_relative 'base_parser'

module Parser
  class OzonParser < BaseParser
    def run(product_url)
      begin
        html = fetch_page_with_selenium(product_url)
        result = parse_page(html)
        formatted_output = format_output(result)
        return formatted_output
      rescue StandardError => e
        puts "Error parsing URL #{product_url}: #{e.message}"
        puts e.backtrace
        return "Ошибка: #{e.message}"
      end
    end

    private

def parse_page(html)
  doc = Nokogiri::HTML(html)
  result = {
    наименование: parse_name(html, doc),
    цена: parse_price(html, doc),
    рейтинг_товара: parse_rating(html, doc),
    количество_отзывов: parse_reviews_count(html, doc),
    бренд: parse_brand(html, doc),
    тип_продукта: parse_product_type(html, doc),
    вес: parse_weight(html, doc)
  }
end

def parse_name(html, doc)
  doc.at_css('h1.qm7_28.tsHeadline550Medium').text.strip
rescue => e
  puts "Error parsing name: #{e.message}"
  'нет'
end

def parse_price(html, doc)
  doc.at_css('div.mq3_28 span.mq1_28.qm5_28').text.gsub(/[ ₽\s]+/, '').to_i
rescue => e
  puts "Error parsing price: #{e.message}"
  'нет'
end

def parse_rating(html, doc)
  doc.at_css('div.ga100-a2.tsBodyControl500Medium').text.match(/(\d+\.\d+)/)[1].to_f
rescue => e
  puts "Error parsing rating: #{e.message}"
  'нет'
end

def parse_reviews_count(html, doc)
  doc.at_css('div.ga100-a2.tsBodyControl500Medium').text.match(/(\d+)\sотзыва/)[1].to_i
rescue => e
  puts "Error parsing reviews count: #{e.message}"
  'нет'
end

def parse_brand(html, doc)
  doc.at_css('a.tsCompactControl500Medium').text.strip
rescue => e
  puts "Error parsing brand: #{e.message}"
  'нет'
end

def parse_product_type(html, doc)
  doc.at_css('span.tsBody400Small').text.strip
rescue => e
  puts "Error parsing product type: #{e.message}"
  'нет'
end

def parse_weight(html, doc)
  doc.at_css('div.uk7_28.kq6_28').text.strip.match(/(\d+\.\d+)\sкг/)[1].to_f
rescue => e
  puts "Error parsing weight: #{e.message}"
  'нет'
end
  end
end

if __FILE__ == $0
  url = "https://www.ozon.ru/product/rebryshki-svinye-v-marinade-appetitnye-1-2-1-5-kg-cherkizovo-ohlazhdennoe-711016451/?at=83tB5xxnZUVzPY66t6oZrV1iz8P1DYFpLGzRkH0rnMR0&ectx=1&miniapp=supermarket&miniapp=supermarket"
  parser = Parser::OzonParser.new
  result = parser.run(url)
  puts "#{result}"
end
