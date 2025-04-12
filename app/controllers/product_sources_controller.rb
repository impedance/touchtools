require 'logger'

class ProductSourcesController < ApplicationController
  # before_action :authenticate_user!

  def index
    @product_source = ProductSource.new
    @product_sources = current_user.product_sources.order(created_at: :desc)
  end

def create
  url = product_source_params[:url]
  logger.info "Попытка обработать URL: #{url}"

  begin
    product_info = fetch_product_info(url)
    parser_ok = product_info.is_a?(Hash) && product_info[:ошибка].nil?

    if parser_ok
      @product_source = create_product_source(url, product_info)
      if @product_source.persisted?
        create_product_metrics(@product_source, product_info)
        logger.info "Успешное сохранение метрик продукта для ссылки: #{@product_source.url}"
        redirect_to product_sources_path, notice: 'Ссылка успешно добавлена! Данные успешно спаршены и сохранены.'
      else
        logger.error "Невозможно сохранить ссылку: #{@product_source.url}, ошибки: #{@product_source.errors.full_messages.join(', ')}"
        redirect_to product_sources_path, alert: "Ссылка успешно добавлена, но не удалось сохранить: #{@product_source.errors.full_messages.join(', ')}"
      end
    else
      handle_error(product_info[:ошибка] || "Неизвестная ошибка при парсинге.")
    end
  rescue URI::InvalidURIError => e
    handle_error("Некорректный URL: #{e.message}")
  rescue ArgumentError => e
    handle_error("Неизвестный провайдер для URL: #{e.message}")
  rescue StandardError => e
    handle_error("Произошла внутренняя ошибка: #{e.message}")
  end
end

private

def fetch_product_info(url)
  parser = get_parser(url)
  parser.get_product_info(ProductSource.new(url: url))
end

def create_product_source(url, product_info)
  current_user.product_sources.new(
    url: url,
    name: product_info[:название]
  ).tap do |product_source|
    logger.info "Получена информация о продукте: #{product_info.inspect}"
    product_source.save
  end
end

def create_product_metrics(product_source, product_info)
  product_source.product_metrics.create(
    rating: product_info[:рейтинг],
    reviews_count: product_info[:всего_оценок],
    collected_at: Time.current
  )
end

def handle_error(error_message)
  logger.error "Ошибка при парсинге ссылки: #{product_source_params[:url]}, ошибка: #{error_message}"
  redirect_to product_sources_path, alert: "Произошла ошибка при парсинге: #{error_message}"
end

  private

  def get_parser(url)
    Parser::ParserFactory.create(url)
  end

  def product_source_params
    params.require(:product_source).permit(:url, :name)
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
