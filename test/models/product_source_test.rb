require 'test_helper'

class ProductSourceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one) # Assuming you have a fixture for users
  end

  test "should create product source with valid attributes" do
    product_source = @user.product_sources.build(
      url: "https://lenta.com/product/example-123",
      name: "Example Product"
    )

    assert product_source.save
  end

  test "should not create product source without url" do
    product_source = @user.product_sources.build(
      name: "Example Product"
    )

    assert_not product_source.save
    assert_includes product_source.errors.full_messages, "Url должен быть валидным URL"
  end

  test "should not create product source without name" do
    product_source = @user.product_sources.build(
      url: "https://lenta.com/product/example-123"
    )

    assert_not product_source.save
    assert_includes product_source.errors.full_messages, "Name не может быть пустым"
  end

  test "should not create product source with too long name" do
    product_source = @user.product_sources.build(
      url: "https://lenta.com/product/example-123",
      name: "a" * 256
    )

    assert_not product_source.save
    assert_includes product_source.errors.full_messages, "Name слишком длинное (максимум 255 символов)"
  end

  test "should not create product source with invalid url" do
    product_source = @user.product_sources.build(
      url: "invalid-url",
      name: "Example Product"
    )

    assert_not product_source.save
    assert_includes product_source.errors.full_messages, "Url должен быть валидным URL"
  end
end
