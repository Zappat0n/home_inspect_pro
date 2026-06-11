# frozen_string_literal: true

class SignInPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_page
    visit new_user_session_path
  end

  def fill_in_with(email, password)
    fill_in "Email", with: email
    fill_in "Password", with: password
  end

  def submit
    click_button I18n.t("devise.views.sessions.submit")
  end

  def sign_out
    click_on I18n.t("devise.views.links.sign_out")
  end

  def has_signed_in_message?
    has_content?(I18n.t("devise.sessions.signed_in"))
  end

  def has_signed_out_message?
    has_content?(I18n.t("devise.sessions.signed_out"))
  end

  def has_invalid_credentials_message?
    has_content?(I18n.t("devise.failure.invalid", authentication_keys: "email"))
  end

  def has_not_found_message?
    has_content?(I18n.t("devise.failure.not_found_in_database", authentication_keys: "email"))
  end
end
