class ProductsController < ApplicationController
  def index
    @products = ProductSource.all
  end

  def search
    @providers = ProductSource.distinct.pluck(:provider_type)
    @products = []
  end

  def show
    @product = ProductSource.find(params[:id])
    @metrics = @product.product_metrics.order(collected_at: :asc)
  end

  def find
    query = params[:query].to_s.strip
    return redirect_to search_products_path, alert: 'Введите поисковый запрос' if query.blank?

    @products = ProductSource.by_provider(params[:provider])
                             .search_by_name(query)
                             .limit(50)

    if @products.empty?
      flash.now[:alert] = 'Товары не найдены'
      render :search
    elsif @products.count == 1
      redirect_to product_path(@products.first)
    else
      render 'products/index'
    end
  end
end
