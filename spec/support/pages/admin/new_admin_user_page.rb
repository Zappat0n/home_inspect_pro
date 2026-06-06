# frozen_string_literal: true

class NewAdminUserPage
  include Capybara::DSL

  def visit_page
    visit RailsAdmin::Engine.routes.url_helpers.new_path(model_name: "admin_user")
  end

  def fill_in_with(email, password, password_confirmation)
    fill_in "Email", with: email
    fill_in "Password", with: password
    fill_in "Password confirmation", with: password_confirmation
  end

  def submit
    click_button "Save"
  end

  def has_success_message?
    has_content?("successfully created")
  end

  def has_update_message?
    has_content?("successfully updated")
  end

  def has_errors?
    has_content?("can't be blank")
  end
end
