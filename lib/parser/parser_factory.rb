# lib/parser/parser_factory.rb
require 'uri'

module Parser
  class ParserFactory
    def self.create(url)
      uri = URI.parse(url)
      host = uri.host

      case host
      when /lenta\.com$/
        LentaParser.new
      when /magnit\.ru$/
        MagnitParser.new
      else
        raise ArgumentError, "Unknown provider for URL: #{url}"
      end
    end
  end
end
