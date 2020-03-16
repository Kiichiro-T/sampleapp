# frozen_string_literal: true

module GroupsHelper
  def current_user_group
    Group.my_own_group(current_user)
  end
end
