# frozen_string_literal: true

class Inspections::IndexPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_page
    visit inspections_path
  end

  def click_new_inspection
    click_link I18n.t("inspections.index.new_button")
  end

  def click_inspection(inspection)
    click_link inspection.property_address
  end

  def click_empty_state_cta
    click_link I18n.t("inspections.index.empty_cta")
  end

  def has_heading?
    has_content?(I18n.t("inspections.index.title"))
  end

  def has_empty_state?
    has_content?(I18n.t("inspections.index.empty"))
  end

  def has_inspection_listed?(inspection)
    has_content?(inspection.property_address)
  end

  def has_no_inspection_listed?(inspection)
    has_no_content?(inspection.property_address)
  end

  def has_success_message?
    has_content?(I18n.t("inspections.create.success"))
  end
end
