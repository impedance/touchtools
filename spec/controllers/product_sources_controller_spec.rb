require 'rails_helper'

RSpec.describe ProductSourcesController, type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }

  describe 'POST #create' do
    before { sign_in user }

    context 'with Lenta URL' do
      let(:lenta_url) { 'https://lenta.com/product/12345' }
      let(:product_info) { { название: 'Lenta Product', рейтинг: 4.5, всего_оценок: 100 } }

      it 'uses LentaParser and creates product source' do
        lenta_parser = double('LentaParser')
        allow(lenta_parser).to receive(:get_product_info).with(instance_of(ProductSource)).and_return(product_info)
        allow_any_instance_of(ProductSourcesController).to receive(:get_parser).with(lenta_url).and_return(lenta_parser)

        expect {
          post product_sources_path, params: { product_source: { url: lenta_url } }
        }.to change(ProductSource, :count).by(1)

        product_source = ProductSource.last
        expect(product_source.url).to eq(lenta_url)
        expect(product_source.name).to eq('Lenta Product')

        metric = product_source.product_metrics.last
        expect(metric.rating).to eq(4.5)
        expect(metric.reviews_count).to eq(100)
      end
    end

    context 'with invalid URL' do
      let(:invalid_url) { 'lenta.ru/product/12345' }

      it 'shows error message and does not create product source' do
        expect {
          post product_sources_path, params: { product_source: { url: invalid_url } }
        }.not_to change(ProductSource, :count)

        expect(flash[:alert]).to include('Неизвестный провайдер для URL')
      end
    end

    context 'with unknown provider URL' do
      let(:unknown_url) { 'https://unknown.ru/product/12345' }

      it 'shows error message and does not create product source' do
        expect {
          post product_sources_path, params: { product_source: { url: unknown_url } }
        }.not_to change(ProductSource, :count)

        expect(flash[:alert]).to include('Неизвестный провайдер для URL')
      end
    end

    context 'with internal error' do
      let(:error_url) { 'https://lenta.com/product/12345' }

      it 'shows error message and does not create product source' do
        lenta_parser = double('LentaParser')
        allow(lenta_parser).to receive(:get_product_info).with(instance_of(ProductSource)).and_raise(StandardError.new('Исключение при парсинге'))
        allow_any_instance_of(ProductSourcesController).to receive(:get_parser).with(error_url).and_return(lenta_parser)

        expect {
          post product_sources_path, params: { product_source: { url: error_url } }
        }.not_to change(ProductSource, :count)

        expect(flash[:alert]).to eq('Произошла внутренняя ошибка при парсинге: Произошла внутренняя ошибка: Исключение при парсинге')
      end
    end
  end

  describe 'GET #new' do
    before { sign_in user }
    
    it 'returns success response' do
      get new_product_source_url
      expect(response).to be_successful
    end
  end
end
