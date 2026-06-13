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

  def has_edit_link?
    has_link?(I18n.t("inspection_templates.show.edit"))
  end

  def has_no_edit_link?
    has_no_link?(I18n.t("inspection_templates.show.edit"))
  end

  def has_category?(name)
    has_css?("[data-testid='category-name']", text: name)
  end

  def has_item_in_category?(_category_name, item_name)
    has_content?(item_name)
  end

  def has_severity_badge?(severity)
    has_css?("[data-testid='severity-badge']", text: I18n.t("checklist_items.severity.#{severity}"))
  end

  def has_photo_badge?
    has_content?(I18n.t("inspection_templates.show.allows_photo"))
  end

  def has_no_photo_badge?
    has_no_content?(I18n.t("inspection_templates.show.allows_photo"))
  end
end
