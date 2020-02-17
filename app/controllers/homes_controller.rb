class HomesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  def index
  end
end
