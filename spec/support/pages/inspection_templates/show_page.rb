# frozen_string_literal: true

class InspectionTemplates::ShowPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_page(template)
    visit inspection_template_path(template)
  end

  def has_heading?(template)
    has_content?(template.name)
  end

  def has_success_message?
    has_content?(I18n.t("inspection_templates.create.success"))
  end

  def has_update_success_message?
    has_content?(I18n.t("inspection_templates.update.success"))
  end

  def has_items_count?(count)
    has_content?(I18n.t("inspection_templates.show.items_count", count: count))
  end
end
