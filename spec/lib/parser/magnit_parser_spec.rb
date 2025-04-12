require 'rails_helper'
require_relative '../../../lib/parser/magnit_parser'

RSpec.describe MagnitParser do
  let(:html_response) do
    <<-HTML
      <html>
        <body>
          <h1 class="product-card__title">Sample Product</h1>
          <div class="product-card__brand">Sample Brand</div>
          <div class="product-card__description">Product description</div>
          
          <section data-v-ea40eff3>
            <div class="product-details-price__current"><span>100,50</span></div>
            <div class="product-details-price__old"><span>120,00</span></div>
            <div class="pl-label_discount"><div class="pl-label__content">-20%</div></div>
          </section>
          
          <div class="product-rating">
            <div class="product-rating-score">4.5</div>
            <div class="product-rating-count">100 оценок · 50 отзывов</div>
          </div>
          
          <table class="product-card__characteristics">
            <tr><td>Weight</td><td>1kg</td></tr>
            <tr><td>Color</td><td>Red</td></tr>
          </table>
          
          <div class="breadcrumbs">
            <div class="breadcrumbs__item">Category</div>
            <div class="breadcrumbs__item">Subcategory</div>
            <div class="breadcrumbs__item">Product</div>
          </div>
          
          <div class="product-card__availability">In stock</div>
          
          <div class="product-card__gallery">
            <img src="image1.jpg">
            <img src="image2.jpg">
          </div>
        </body>
      </html>
    HTML
  end

  let(:product_url) { "https://magnit.ru/product/sample-product" }
  let(:product_source) { double("ProductSource", url: product_url) }
  let(:parser) { MagnitParser.new }

  before do
    stub_request(:get, product_url)
      .with(headers: {
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3',
        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      })
      .to_return(status: 200, body: html_response)
  end

  describe '#parse' do
    it 'extracts product name' do
      result = parser.parse(product_source)
      expect(result[:название]).to eq("Sample Product")
    end

    it 'extracts brand' do
      result = parser.parse(product_source)
      expect(result[:бренд]).to eq("Sample Brand")
    end

    it 'extracts description' do
      result = parser.parse(product_source)
      expect(result[:описание]).to eq("Product description")
    end

    it 'extracts prices' do
      result = parser.parse(product_source)
      expect(result[:обычная_цена]).to eq(120.0)
      expect(result[:цена_со_скидкой]).to eq(100.5)
      expect(result[:скидка]).to eq("20")
    end

    it 'extracts rating info' do
      result = parser.parse(product_source)
      expect(result[:рейтинг]).to eq(4.5)
      expect(result[:количество_оценок]).to eq(100)
      expect(result[:количество_отзывов]).to eq(50)
    end

    it 'extracts characteristics' do
      result = parser.parse(product_source)
      expect(result[:характеристики]).to eq({
        "Weight" => "1kg",
        "Color" => "Red"
      })
    end

    it 'extracts categories' do
      result = parser.parse(product_source)
      expect(result[:категории]).to eq({
        основная: "Product",
        подкатегория: "Subcategory"
      })
    end

    it 'extracts availability' do
      result = parser.parse(product_source)
      expect(result[:наличие]).to eq("In stock")
    end

    it 'extracts images' do
      result = parser.parse(product_source)
      expect(result[:изображения]).to eq(["image1.jpg", "image2.jpg"])
    end

    context 'when request fails' do
      before do
        stub_request(:get, product_url).to_return(status: 404)
      end

      it 'returns error message' do
        result = parser.parse(product_source)
        expect(result[:ошибка]).to match(/404/)
      end
    end
  end
end
