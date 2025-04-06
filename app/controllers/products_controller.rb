class ProductsController < ApplicationController
  def search
    @providers = ProductSource.distinct.pluck(:provider_type)
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
      redirect_to search_products_path, alert: 'Товары не найдены'
    elsif @products.count == 1
      redirect_to product_path(@products.first)
    else
      render :index
    end
  end
end
