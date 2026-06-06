# frozen_string_literal: true

class AdminUsersPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_page
    visit "/admin/user"
  end

  def has_user?(user)
    has_content?(user.email)
  end

  def click_new
    click_link "Add new"
  end

  def click_edit(user)
    find("tr", text: user.email).find(".edit_member_link a").click
  end

  def click_show(user)
    find("tr", text: user.email).find(".show_member_link a").click
  end

  def click_delete(user)
    find("tr", text: user.email).find(".delete_member_link a").click
  end

  def has_success_deleted_message?
    has_content?("User successfully deleted")
  end

  def has_no_user?(user)
    has_no_content?(user.email)
  end
end
