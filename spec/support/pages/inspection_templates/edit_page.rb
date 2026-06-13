# frozen_string_literal: true

class InspectionTemplates::EditPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include ActionView::RecordIdentifier

  def visit_page(template)
    visit edit_inspection_template_path(template)
  end

  def fill_name(name)
    find("[data-testid='template-name-input']").fill_in(with: name)
  end

  def submit
    find("[data-testid='template-name-input']").send_keys(:tab)
  end

  def has_heading?(template)
    has_content?(I18n.t("inspection_templates.edit.title", name: template.name))
  end

  def has_error?
    has_content?("prohibited this inspection template from being saved")
  end

  def add_item(category, name:, description: "", severity: "info")
    within(category_section(category)) do
      page.execute_script("arguments[0].setAttribute('open', '')", find("details", visible: :all))
      within("details") do
        fill_in "Name", with: name
        fill_in "Description", with: description
        select I18n.t("checklist_items.severity.#{severity}"), from: "Severity"
        click_on I18n.t("checklist_items.form.submit")
      end
    end
  end

  def edit_item(item, new_name:)
    within("##{dom_id(item)}") do
      page.execute_script(
        "arguments[0].classList.remove('hidden')",
        find("[data-inline-edit-target='form']", visible: :all),
      )
      fill_in "Name", with: new_name
      click_on I18n.t("checklist_items.form.submit")
    end
  end

  def delete_item(item)
    within("##{dom_id(item)}") do
      page.accept_confirm do
        click_on I18n.t("checklist_items.delete.button")
      end
    end
  end

  def has_item?(name)
    has_content?(name)
  end

  def has_no_item?(name)
    has_no_content?(name)
  end

  def has_updated_name?(name)
    has_css?("[data-testid='template-name-input'][value='#{name}']")
  end

  private

  def category_section(category)
    find("h3", text: /\A#{Regexp.escape(category)}\z/).ancestor("div.mb-6")
  end
end
