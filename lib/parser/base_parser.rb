require 'net/http'
require 'uri'
require 'nokogiri'
require 'logger'

module Parser
  class BaseParser
    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG
      @user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    end

    def fetch_page(product_url)
      uri = URI(product_url)
      request = Net::HTTP::Get.new(uri)
      request['User-Agent'] = @user_agent
      request['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      request['Accept-Language'] = 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3'

      response = nil
      redirect_limit = 5
      while redirect_limit > 0
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          response = http.request(request)
          if response.is_a?(Net::HTTPRedirection)
            uri = URI.parse(response['location'])
            request = Net::HTTP::Get.new(uri)
            request['User-Agent'] = @user_agent
            request['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
            request['Accept-Language'] = 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3'
            product_url = uri.to_s # Update the URL for the next iteration
            uri = URI(product_url) # Update the URI object
            redirect_limit -= 1
          else
            break
          end
        end
      end

      response.value
      response.body
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
