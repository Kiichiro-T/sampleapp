# frozen_string_literal: true

module ApplicationHelper
  def full_title(page_title = '')
    base_title = 'Circle Management'
    if page_title.empty?
      base_title
    else
      page_title + ' | ' + base_title
    end
  end

  def current_user_group
    group = Group.my_own_group(current_user)
    group if group
  end
end
