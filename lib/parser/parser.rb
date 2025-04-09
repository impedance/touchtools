# lib/parser/parser.rb
module Parser
  class Parser
    def parse(product_source)
      raise NotImplementedError, "Subclasses must implement the 'parse' method"
    end
  end
end
