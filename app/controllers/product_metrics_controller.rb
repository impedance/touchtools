class ProductMetricsController < ApplicationController
  def index
    @metrics = ProductMetric.where(
      product_source_id: params[:product_source_id]
    ).order(collected_at: :desc)
  end
end
