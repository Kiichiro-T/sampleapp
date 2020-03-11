class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :prepare_new_order, only: [:paypal_create]
  def index
    @products = Product.all
  end

  def submit
    @order = Orders::Paypal.finish(order_params[:token])
    if @order&.save # @userがnilだとしてもエラーにならない(ぼっち演算子)
      if @order.paid?
        # Success is rendered when order is paid and saved
        return render html: SUCCESS_MESSAGE
      elsif @order.failed? && !@@order.error_message.blank?
        # Render error only if order failed and there is an error_message
        return render html: @order.error_message
      end
    end
    render html: FAILURE_MESSAGE
  end

  def paypal_create
    result = Orders::Paypal.create_payment(order: @order, product: @product)
    if result
      render json: { token: result }, status: :ok
    else
      render json: { error: FAILURE_MESSAGE }, status: :unprocessable_entity
    end
  end

  def paypal_execute
    if Orders::Paypal.execute_payment(payment_id: params[:paymentID], payer_id: params[:payerID])
      render json: {}, status: :ok
    else
      render json: { error: FAILURE_MESSAGE }, status: :unprocessable_entity
    end
  end

  private

    # orderの初期化とuser, product, priceのセット
    def prepare_new_order
      @order = Order.new(order_params)
      @order.user_id = current_user.id
      @product = Product.find(@order.product_id)
      @order.proce_cents = @product.price_cents
    end

    def order_params
      params.require(:order).permit(:product_id, :token, :charge_id)
    end
end
