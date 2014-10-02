require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  test "products attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product price must be positive" do
    product = Product.new(
      title: "Chatka Puchatka",
      description: "Dla dzieci",
      image_url: "chatka.jpg")
    product.price = -1
    assert product.invalid?
    assert_equal ["should be positive."], product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal ["should be positive."], product.errors[:price]

    product.price = 0.001
    assert product.invalid?
    assert_equal ["should be positive."], product.errors[:price]

    product.price = 0.01
    assert product.valid?
  end

  def new_product(image_url)
    product = Product.new(
      title: "Chatka Puchatka",
      description: "Dla dzieci",
      price: "6.66",
      image_url: image_url)
  end

  test "image_url should end with .jpg, .gif, or .png" do
    ok = %w{ a.jpg a.gif a.png A.jpg A.PNG http://www.a.com/a.GIF }
    bad = %w{ a.doc a a.pdf a.gif.txt a }
    ok.each do |name|
      assert new_product(name).valid?, "#{name} should be valid"
    end
    bad.each do |name|
      assert new_product(name).invalid?, "#{name} should not be valid"
    end
  end

  test "title must by unique" do
    product = Product.new(
      title: products(:ruby).title,
      description: "Bla",
      image_url: "bla.jpg",
      price: 666)
    assert product.invalid?
    assert_equal [I18n.translate("errors.messages.taken")], product.errors[:title]
  end

  test "title must be at least ten characters long" do
    product = Product.new(
      description: "bla",
      image_url: "a.jpg",
      price: 666)
    product.title = "a"
    assert product.invalid?
    assert_equal ["is too short (minimum is 10 characters)"], product.errors[:title]
    product.title = "1234567891"
    assert product.valid?
  end
end
