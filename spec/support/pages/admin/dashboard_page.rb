# frozen_string_literal: true

class AdminDashboardPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_page
    visit RailsAdmin::Engine.routes.url_helpers.dashboard_path
  end

  def has_heading?
    has_content?(I18n.t("admin.actions.dashboard.title"))
  end

  def has_model?(name)
    has_content?(name)
  end

  def click_model(name)
    click_link name, match: :first
  end

  def has_list_heading_for?(name)
    has_content?("List of #{name}")
  end

  def has_count?
    has_css?(".progress-bar")
  end

  def sign_out
    click_on I18n.t("admin.misc.log_out")
  end

  def has_logout_button?
    has_content?(I18n.t("admin.misc.log_out"))
  end

  def has_dashboard_path?
    uri = URI.parse(current_url)
    ["/admin", "/admin/"].include?(uri.path)
  end
end
