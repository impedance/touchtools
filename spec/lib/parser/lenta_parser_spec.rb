require 'rails_helper'
require_relative '../../../lib/parser/lenta_parser'

RSpec.describe LentaParser do
  let(:json_response) do
    {
      "title" => "Sample Product",
      "rates" => {
        "averageRate" => 4.5,
        "totalCount" => 100,
        "scores" => {
          "rate1" => 5,
          "rate2" => 10,
          "rate3" => 20,
          "rate4" => 30,
          "rate5" => 35
        }
      },
      "comments" => [
        { "text" => "Great product!" },
        { "text" => "Not bad." }
      ]
    }.to_json
  end

  let(:product_url) { "https://lenta.com/product/sample-product-123/" }
  let(:product_source) { double("ProductSource", url: product_url) }
  let(:parser) { LentaParser.new }

    before do
      stub_request(:get, "https://lenta.com/api/v2/stores/1352/skus/123/").to_return(status: 200, body: json_response)
    end

  describe '#parse' do
    it 'extracts product name' do
      result = parser.parse(product_source)
      expect(result[:название]).to eq("Sample Product")
    end

    it 'extracts product rating' do
      result = parser.parse(product_source)
      expect(result[:рейтинг]).to eq(4.5)
    end

    it 'extracts total number of reviews' do
      result = parser.parse(product_source)
      expect(result[:всего_оценок]).to eq(100)
    end

    it 'extracts distribution of ratings' do
      result = parser.parse(product_source)
expect(result[:распределение_оценок]).to eq({
  "1 звезда" => 5,
  "2 звезды" => 10,
  "3 звезды" => 20,
  "4 звезды" => 30,
  "5 звезд" => 35
})
    end

    it 'extracts reviews' do
      result = parser.parse(product_source)
      expect(result[:отзывы]).to eq(["Great product!", "Not bad."])
    end

    it 'extracts product URL' do
      result = parser.parse(product_source)
      expect(result[:url]).to eq(product_url)
    end
  end
end
