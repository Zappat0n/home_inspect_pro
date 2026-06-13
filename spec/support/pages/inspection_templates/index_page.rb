# frozen_string_literal: true

class InspectionTemplates::IndexPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def visit_page
    visit inspection_templates_path
  end

  def has_system_template_section?
    has_content?(I18n.t("inspection_templates.index.system_templates"))
  end

  def has_my_templates_section?
    has_content?(I18n.t("inspection_templates.index.my_templates"))
  end

  def has_template_card?(name)
    has_css?("[data-testid='template-name']", text: /\A#{Regexp.escape(name)}\z/)
  end

  def has_no_template_card?(name)
    has_no_css?("[data-testid='template-name']", text: /\A#{Regexp.escape(name)}\z/)
  end

  def duplicate_template(name)
    within(template_card(name)) do
      click_on I18n.t("inspection_templates.index.duplicate")
    end
  end

  def click_new_template
    click_link I18n.t("inspection_templates.index.new_template")
  end

  def edit_template(name)
    within(template_card(name)) do
      click_link I18n.t("inspection_templates.index.edit")
    end
  end

  def delete_template(name)
    within(template_card(name)) do
      click_on I18n.t("inspection_templates.index.delete")
    end
  end

  def has_success_message?
    has_content?(I18n.t("inspection_templates.create.success"))
  end

  def has_duplicate_success_message?
    has_content?(I18n.t("inspection_templates.duplicate.success"))
  end

  def has_destroy_success_message?
    has_content?(I18n.t("inspection_templates.destroy.success"))
  end

  def has_update_success_message?
    has_content?(I18n.t("inspection_templates.update.success"))
  end

  def has_alert_message?(text)
    has_content?(text)
  end

  private

  def template_card(name)
    find("[data-testid='template-card']", text: name)
  end
end
