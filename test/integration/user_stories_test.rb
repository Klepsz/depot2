require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures :products
  test "buying a product" do
    LineItem.delete_all
    Order.delete_all
    ruby_book = products(:ruby)

    #A user go to the store index page
    get "/"
    assert_response :success
    assert_template "index"

    #They select a product and adding it to their cart
    xml_http_request :post, "/line_items", product_id: ruby_book.id
    assert_response :success

    cart = Cart.find(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product

    #They then checkout
    get "orders/new"
    assert_response :success
    assert_template "new"

    #Client is filling in data and proceed
    post_via_redirect "/orders",
                      order: {
                        name: "Dave Thomas",
                        address: "123 The Street",
                        email: "dave@example.com",
                        pay_type: "Check"}
    assert_response :success
    assert_template "index"
    cart = Cart.find(session[:cart_id])
    assert_equal 0, cart.line_items.size

    #We make sure that the oreder and corresponding line item is created in database
    orders = Order.all
    assert_equal 1, orders.size
    order = orders[0]

    assert_equal "Dave Thomas", order.name
    assert_equal "123 The Street", order.address
    assert_equal "dave@example.com", order.email
    assert_equal "Check", order.pay_type

    assert_equal 1, order.line_items.size
    line_item = order.line_items[0]

    assert_equal ruby_book, line_item.product

    #We make sure that mail has correct address and subject
    mail = ActionMailer::Base.deliveries.last
    assert_equal ["dave@example.com"], mail.to
    assert_equal ["sam@example.com"], mail.from
    assert_equal "Pragmatic Store Order Confirmation", mail.subject
  end
end
