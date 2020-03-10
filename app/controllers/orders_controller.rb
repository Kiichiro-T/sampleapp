class OrdersController < ApplicationController
  before_action :authenticate_user!
  def index
    @products = Product.all
  end

  def submit
  end
end
