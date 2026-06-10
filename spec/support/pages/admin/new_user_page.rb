# frozen_string_literal: true

class AdminNewUserPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_new_page
    visit "/admin/user/new"
  end

  def visit_edit_page(user)
    visit "/admin/user/#{user.id}/edit"
  end

  def fill_in_with(attrs)
    if attrs.key?(:email)
      fill_in "Email", with: attrs[:email]
    end

    if attrs.key?(:password)
      fill_in "Password", with: attrs[:password]
    end

    if attrs.key?(:password_confirmation)
      fill_in "Password confirmation", with: attrs[:password_confirmation]
    end

    return unless attrs.key?(:country)

    select attrs[:country].name, from: "Country"
  end

  def submit
    click_button "Save"
  end

  def has_success_created_message?
    has_content?("User successfully created")
  end

  def has_success_updated_message?
    has_content?("User successfully updated")
  end

  def has_error_message?
    has_content?("can't be blank")
  end
end
