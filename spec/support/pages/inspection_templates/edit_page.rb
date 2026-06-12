# frozen_string_literal: true

class InspectionTemplates::EditPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_page(template)
    visit edit_inspection_template_path(template)
  end

  def fill_name(name)
    find("[data-testid='template-name-input']").fill_in(with: name)
  end

  def submit
    click_on I18n.t("inspection_templates.edit.submit")
  end

  def has_heading?(template)
    has_content?(I18n.t("inspection_templates.edit.title", name: template.name))
  end

  def has_error?
    has_content?("prohibited this inspection template from being saved")
  end
end
