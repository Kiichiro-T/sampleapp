class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :paid_group_cannot_access
  before_action :prepare_new_order, only: [:paypal_create_payment, :paypal_create_subscription]
  def index
    products = Product.all
    @products_purchase = products.where(paypal_plan_name: nil)
    @products_subscription = products - @products_purchase
  end

  def submit
    @order = Orders::Paypal.finish(order_params[:charge_id])
    if @order&.save # @orderがnilだとしてもエラーにならない(ぼっち演算子)
      group = current_user_group
      group.set_paid
      if @order.paid? && group.save
        # Success is rendered when order is paid and saved
        return render html: '成功'
      elsif @order.failed? && !@order.error_message.blank?
        # Render error only if order failed and there is an error_message
        return render html: @order.error_message
      end
    end
    render html: '失敗1'
  end

  def paypal_create_payment
    result = Orders::Paypal.create_payment(order: @order, product: @product)
    if result
      render json: { token: result }, status: :ok
    else
      render json: {error: '失敗2'}, status: :unprocessable_entity
    end
  end

  def paypal_execute_payment
    if Orders::Paypal.execute_payment(payment_id: params[:paymentID], payer_id: params[:payerID])
      render json: {}, status: :ok
    else
      render json: {error: '失敗3'}, status: :unprocessable_entity
    end
  end

  def paypal_create_subscription
    result = Orders::Paypal.create_subscription(order: @order, product: @product)
    if result
      render json: { token: result }, status: :ok
    else
      render json: {error: '失敗4'}, status: :unprocessable_entity
    end
  end

  def paypal_execute_subscription
    result = Orders::Paypal.execute_subscription(token: params[:subscriptionToken])
    if result
      render json: { id: result }, status: :ok
    else
      render json: {error: '失敗5'}, status: :unprocessable_entity
    end
  end

  private

    # orderの初期化とuser, product, priceのセット
    def prepare_new_order
      @order = Order.new(order_params)
      @order.user_id = current_user.id
      @product = Product.find(@order.product_id)
      @order.price_cents = @product.price_cents
    end

    def order_params
      params.require(:orders).permit(:product_id, :token, :charge_id)
    end

    def paid_group_cannot_access
      if current_user_group
        return unless current_user_group.payment_status == 'paid'

        flash[:note] = '購読済みです'
        redirect_to root_url
      else
        flash[:note] = '権限がありません'
        redirect_to root_url
      end
    end
end
