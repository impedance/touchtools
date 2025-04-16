require "test_helper"

class ProductMetricsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get product_source_product_metrics_url(product_sources(:one))
    assert_response :success
  end
end
