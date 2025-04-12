require "test_helper"

require 'test_helper'
require 'mocha/minitest'
require 'devise'

class ProductSourcesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "create should use LentaParser for Lenta URLs" do
    user = users(:one)
    sign_in user # Sign in the user from the fixture
    @request.session[:user_id] = user.id

    lenta_url = "https://lenta.ru/product/12345"
    product_info = { название: "Lenta Product", рейтинг: 4.5, всего_оценок: 100 }

    lenta_parser = mock()
    lenta_parser.expects(:get_product_info).with(lenta_url).returns(product_info)

    ProductSourcesController.any_instance.expects(:get_parser).with(lenta_url).returns(lenta_parser)

    assert_difference('ProductSource.count') do
      post product_sources_path, params: { product_source: { url: lenta_url } }
    end

    product_source = ProductSource.last
    assert_equal lenta_url, product_source.url
    assert_equal "Lenta Product", product_source.name

    assert_equal 4.5, product_source.product_metrics.last.rating
    assert_equal 100, product_source.product_metrics.last.reviews_count
  end

  test "should get new" do
    get new_product_source_url
    assert_response :success
  end
end
