class BillingPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_page
    visit billing_path
  end

  def has_subscribe_monthly_button?
    has_content?(I18n.t("billing.show.subscribe_monthly"))
  end

  def has_subscribe_yearly_button?
    has_content?(I18n.t("billing.show.subscribe_yearly"))
  end

  def has_sign_in_form?
    has_content?(I18n.t("devise.views.sessions.submit"))
  end
end
