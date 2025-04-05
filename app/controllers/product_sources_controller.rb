class ProductSourcesController < ApplicationController
  # before_action :authenticate_user!
  
  def index
    @product_source = ProductSource.new
    @product_sources = current_user.product_sources.order(created_at: :desc)
  end

  def create
    @product_source = current_user.product_sources.new(product_source_params)

    if @product_source.save
      redirect_to product_sources_path, 
                  notice: 'Ссылка успешно добавлена! Парсинг начнется в ближайшее время.'
    else
      @product_sources = current_user.product_sources.order(created_at: :desc)
      render :index
    end
  end

  private

  def product_source_params
    params.require(:product_source).permit(:url)
  end
end