class ProductSourcesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @product_sources = current_user.product_sources.includes(:product_metrics)
  end

  def new
    @product_source = current_user.product_sources.new
  end

  def create
    @product_source = current_user.product_sources.new(product_source_params)
    if @product_source.save
      redirect_to product_sources_path, notice: 'Товар добавлен'
    else
      render :new
    end
  end

  private

  def product_source_params
    params.require(:product_source).permit(:url, :provider_type)
  end
end
