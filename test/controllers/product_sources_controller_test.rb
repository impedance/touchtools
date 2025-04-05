require "test_helper"

class ProductSourcesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get product_sources_index_url
    assert_response :success
  end

  test "should get new" do
    get product_sources_new_url
    assert_response :success
  end

  test "should get create" do
    get product_sources_create_url
    assert_response :success
  end
end
