# frozen_string_literal: true

class PasswordResetPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_forgot_page
    visit new_user_password_path
  end

  def visit_reset_page(token)
    visit edit_user_password_path(reset_password_token: token)
  end

  def fill_email_for_reset(email)
    fill_in "Email", with: email
  end

  def submit_forgot
    click_button I18n.t("devise.views.passwords.submit")
  end

  def fill_new_password(password:, password_confirmation:)
    fill_in I18n.t("devise.views.passwords.edit.password_label"), with: password
    fill_in I18n.t("devise.views.passwords.edit.password_confirmation_label"), with: password_confirmation
  end

  def submit_new_password
    click_button I18n.t("devise.views.passwords.edit.submit")
  end

  def has_sent_instructions_message?
    has_content?(I18n.t("devise.passwords.send_instructions"))
  end

  def has_password_updated_message?
    has_content?(I18n.t("devise.passwords.updated"))
  end

  def has_expired_token_message?
    has_content?("#{User.human_attribute_name(:reset_password_token)} #{I18n.t('errors.messages.expired')}")
  end
end
