class Events::TransactionsController < TransactionsController
  def new
    @event = Event.find(params[:event_id])
    @group = Group.find(@event.group_id)
    @transaction = Event::Transaction.new
    @users = []
    GroupUser.where(group_id: @group.id).each do |relationship|
      user = User.find(relationship.user_id)
      unless Event::Transaction.where(group_id: @group.id, event_id: @event.id, debtor_id: relationship.user_id)
        @users << user
      end
    end
  end

  def create
    @event = Event.find(params[:event_id])
    @group = Group.find(@event.group_id)
    @transaction = Event::Transaction.new(transaction_params)
    @users = [] # createでも定義しないといけない
    GroupUser.where(group_id: @group.id).each do |relationship|
      user = User.find(relationship.user_id)
      unless Event::Transaction.where(group_id: @group.id, event_id: @event.id, debtor_id: relationship.user_id)
        @users << user
      end
    end
    if @transaction.save
      flash[:success] = "作成成功！"
      redirect_to group_event_url(group_id: @group.id, id: @event.id)
    else
      render 'new'
    end
  end

  def transaction_params
    params.require(:event_transaction).permit(:debtor_id, :creditor_id, :event_id, :group_id, :deadline, :debt, :payment, :type)
  end
end