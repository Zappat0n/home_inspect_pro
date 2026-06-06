# frozen_string_literal: true

class AdminUserListPage
  include Capybara::DSL

  def visit_page
    visit RailsAdmin::Engine.routes.url_helpers.index_path(model_name: "admin_user")
  end

  def has_page_title?
    has_content?("List of Admin users")
  end

  def has_admin_user?(admin_user)
    has_content?(admin_user.email)
  end

  def has_no_admin_user?(admin_user)
    has_no_content?(admin_user.email)
  end

  def has_success_message?
    has_content?("successfully")
  end

  def click_new
    click_link "Add new"
  end

  def click_edit(admin_user)
    row = find("tr.admin_user_row", text: admin_user.email)
    row.find(".edit_member_link a").click
  end

  def click_show(admin_user)
    row = find("tr.admin_user_row", text: admin_user.email)
    row.find(".show_member_link a").click
  end

  def click_delete(admin_user)
    row = find("tr.admin_user_row", text: admin_user.email)
    row.find(".delete_member_link a").click
  end

  def confirm_delete
    click_button I18n.t("admin.form.confirmation")
  end

  def has_details_for?(admin_user)
    has_content?(admin_user.email)
  end
end
