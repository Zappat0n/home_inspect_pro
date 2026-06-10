# frozen_string_literal: true

class PwaInstallBannerPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_home
    visit root_path
  end

  def visit_inspection(inspection)
    visit inspection_path(inspection)
  end

  def has_banner?
    has_css?("[data-pwa-install-target='banner']")
  end

  def has_banner_hidden?
    banner = find("[data-pwa-install-target='banner']")
    banner[:class].include?("hidden")
  end

  def has_install_title?
    has_content?(I18n.t("pwa.install.title"))
  end

  def has_install_subtitle?
    has_content?(I18n.t("pwa.install.subtitle"))
  end

  def has_install_button_text?
    has_button?(I18n.t("pwa.install.button"))
  end

  def has_install_button?
    has_css?("[data-action='click->pwa-install#install']")
  end

  def has_dismiss_button?
    has_css?("[data-action='click->pwa-install#dismiss']")
  end
end
