require "test_helper"

class ProductMetricsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get product_metrics_index_url
    assert_response :success
  end
end
