# frozen_string_literal: true

class Inspections::NewPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_page
    visit new_inspection_path
  end

  def fill_in_with(property_address:, client_name:, client_email:)
    fill_in I18n.t("inspections.form.property_address_label"), with: property_address
    fill_in I18n.t("inspections.form.client_name_label"), with: client_name
    fill_in I18n.t("inspections.form.client_email_label"), with: client_email
  end

  def submit
    find(%([data-testid="submit_button"])).click
  end

  def cancel
    find(%([data-testid="cancel_link"])).click
  end

  def has_heading?
    has_content?(I18n.t("inspections.new.title"))
  end

  def has_validation_error?
    has_content?("prohibited this inspection from being saved", wait: 2)
  end

  def has_subscribe_link?
    has_link?(I18n.t("subscription.trial_banner.subscribe"), href: billing_path)
  end

  def has_template_selector?
    has_content?(I18n.t("inspections.form.template_label"))
  end

  def has_template_card?(template)
    has_content?(template.name) &&
      has_content?(I18n.t("inspections.form.template_item_count", count: template.items.count))
  end

  def has_custom_badge?
    has_css?("[data-testid='custom-template-badge']")
  end

  def has_no_custom_badge?
    has_no_css?("[data-testid='custom-template-badge']")
  end

  def select_template(template)
    find("label", text: template.name).click
  end
end
