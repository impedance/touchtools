# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  def search
    @providers = ProductSource.distinct.pluck(:provider_type)

    if request.post? # Если форма отправлена
      query = params[:query].to_s.strip
      if query.blank?
        flash.now[:alert] = 'Введите поисковый запрос'
      else
        @search_results = ProductSource.by_provider(params[:provider])
                                       .search_by_name(query)
                                       .limit(50)
      end
    end
  end

  def show
    @product = ProductSource.find(params[:id])
    @metrics = @product.product_metrics.order(collected_at: :asc)
  end
end
