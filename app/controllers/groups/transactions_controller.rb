class Groups::TransactionsContrller < TransactionsController
  def new
    @group = Group.find(params[:group_id])
    @transaction = Transaction.new
  end
end
  