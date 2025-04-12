require 'logger'

class ProductSourcesController < ApplicationController
  # before_action :authenticate_user!

  def index
    @product_source = ProductSource.new
    @product_sources = current_user.product_sources.order(created_at: :desc)
  end

  def create
    begin
      url = product_source_params[:url]
      logger.info "Попытка обработать URL: #{url}"

      parser = get_parser(product_source_params[:url])
      product_info = parser.get_product_info(ProductSource.new(url: product_source_params[:url]))
      logger.info "Получена информация о продукте: #{product_info.inspect}"

      parser_ok = product_info.is_a?(Hash) && product_info[:ошибка].nil?

    if parser_ok
      @product_source = current_user.product_sources.new(
        url: product_source_params[:url],
        name: product_info[:название]
      )

      if @product_source.save
        logger.info "Сохранена новая ссылка: #{@product_source.url}"
        @product_source.product_metrics.create(
          rating: product_info[:рейтинг],
          reviews_count: product_info[:всего_оценок],
          collected_at: Time.current
        )
        logger.info "Успешное сохранение метрик продукта для ссылки: #{@product_source.url}"
        redirect_to product_sources_path,
                    notice: 'Ссылка успешно добавлена! Данные успешно спаршены и сохранены.'
      else
        logger.error "Невозможно сохранить ссылку: #{@product_source.url}, ошибки: #{@product_source.errors.full_messages.join(', ')}"
        redirect_to product_sources_path,
                    alert: "Ссылка успешно добавлена, но не удалось сохранить: #{@product_source.errors.full_messages.join(', ')}"
      end
    else
      error_message = product_info[:ошибка] || "Неизвестная ошибка при парсинге."
      logger.error "Ошибка при парсинге ссылки: #{product_source_params[:url]}, ошибка: #{error_message}"
      redirect_to product_sources_path,
                  alert: "Произошла ошибка при парсинге: #{error_message}"
    end
  rescue URI::InvalidURIError => e
    error_message = "Некорректный URL: #{e.message}"
    logger.error "Некорректный URL при парсинге ссылки: #{product_source_params[:url]}, ошибка: #{error_message}"
    redirect_to product_sources_path,
                alert: "Некорректный URL: #{error_message}"
  rescue ArgumentError => e
    error_message = "Неизвестный провайдер для URL: #{e.message}"
    logger.error "Неизвестный провайдер при парсинге ссылки: #{product_source_params[:url]}, ошибка: #{error_message}"
    redirect_to product_sources_path,
                alert: "Неизвестный провайдер для URL: #{error_message}"
  rescue StandardError => e
    error_message = "Произошла внутренняя ошибка: #{e.message}"
    logger.error "Внутренняя ошибка при парсинге ссылки: #{product_source_params[:url]}, ошибка: #{error_message}"
    redirect_to product_sources_path,
                alert: "Произошла внутренняя ошибка при парсинге: #{error_message}"
  end
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
