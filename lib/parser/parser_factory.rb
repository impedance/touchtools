# lib/parser/parser_factory.rb
require 'uri'
require_relative 'dixy_parser'

module Parser
  class ParserFactory
    def self.create(url)
      uri = URI.parse(url)
      host = uri.host

      case host
      when /lenta\.com$/
        parser = LentaParser.new
        parser.run(url)
      when /magnit\.ru$/
        parser = MagnitParser.new
        parser.run(url)
      when /dixy\.ru$/
        parser = DixyParser.new
        return parser.run(url)
      else
        raise ArgumentError, "Unknown provider for URL: #{url}"
      end
    end
  end
end
