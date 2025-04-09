# lib/parser/parser_factory.rb
module Parser
  class ParserFactory
    def self.create(product_source)
      case product_source.provider_type
      when 'lenta'
        LentaParser.new
      when 'magnit'
        MagnitParser.new
      else
        raise ArgumentError, "Unknown provider type: #{product_source.provider_type}"
      end
    end
  end
end
