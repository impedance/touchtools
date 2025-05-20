# lib/parser/parser.rb
module Parser
  class Parser
    def run(product_url)
      raise NotImplementedError, "Subclasses must implement the 'run' method"
    end

    def parse(product_source)
      raise NotImplementedError, "Subclasses must implement the 'parse' method"
    end
  end
end
