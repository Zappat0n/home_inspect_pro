# frozen_string_literal: true

class InspectionTemplates::NewPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_page
    visit new_inspection_template_path
  end

  def fill_name(name)
    find("[data-testid='template-name-input']").fill_in(with: name)
  end

  def submit
    click_on I18n.t("inspection_templates.new.submit")
  end

  def has_heading?
    has_content?(I18n.t("inspection_templates.new.title"))
  end

  def has_error?
    has_content?("prohibited this inspection template from being saved")
  end

  def has_blank_name_error?
    has_content?("Name can't be blank")
  end
end
