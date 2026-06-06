# frozen_string_literal: true

class SignUpPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_page
    visit new_user_registration_path
  end

  def fill_in_with(email:, password:, password_confirmation:)
    fill_in "Email", with: email
    fill_in "Password", with: password
    fill_in "Password confirmation", with: password_confirmation
  end

  def submit
    click_button I18n.t("devise.views.registrations.submit")
  end

  def has_signed_up_message?
    has_content?(I18n.t("devise.registrations.signed_up"))
  end

  def has_password_confirmation_mismatch_message?
    has_content?(
      "#{User.human_attribute_name(:password_confirmation)} #{I18n.t(
        'errors.messages.confirmation',
        attribute: User.human_attribute_name(:password),
      )}",
    )
  end

  def has_blank_email_message?
    has_content?("#{User.human_attribute_name(:email)} #{I18n.t('errors.messages.blank')}")
  end
end
