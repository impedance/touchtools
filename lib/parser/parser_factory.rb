# lib/parser/parser_factory.rb
require 'uri'
require_relative 'dixy_parser'
require_relative 'megamarket_parser'
require_relative 'ozon_parser'

module Parser
  class ParserFactory
    def self.create(url)
      uri = URI.parse(url)
      host = uri.host

      case host
      when /lenta\.com$/
        parser = LentaParser.new
        parser.get_product_info(url)
      when /magnit\.ru$/
        parser = MagnitParser.new
        parser.get_product_info(url)
      when /dixy\.ru$/
        parser = DixyParser.new
        parser.run(url)
      when /megamarket\.ru$/
        parser = MegamarketParser.new
        parser.run(url)
      when /ozon\.ru$/
        parser = OzonParser.new
        parser.run(url)
      else
        raise ArgumentError, "Unknown provider for URL: #{url}"
      end
    end
  end
end
