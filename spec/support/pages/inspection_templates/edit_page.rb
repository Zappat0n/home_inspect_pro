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
    click_on I18n.t("inspection_templates.edit.submit")
  end

  def has_heading?(template)
    has_content?(I18n.t("inspection_templates.edit.title", name: template.name))
  end

  def has_error?
    has_content?("prohibited this inspection template from being saved")
  end

  def add_item(category, name:, description: "", severity: "info")
    within(category_section(category)) do
      open_details
      within("details") do
        fill_in "Name", with: name
        fill_in "Description", with: description
        select I18n.t("checklist_items.severity.#{severity}"), from: "Severity"
        set_position_field
        click_on I18n.t("checklist_items.form.submit")
      end
    end
  end

  def edit_item(item, new_name:)
    within("##{dom_id(item)}") do
      click_on I18n.t("checklist_items.edit.button")
      fill_in "Name", with: new_name
      click_on I18n.t("checklist_items.form.submit")
    end
  end

  def delete_item(item)
    within("##{dom_id(item)}") do
      click_on I18n.t("checklist_items.delete.button")
    end
  end

  def has_item?(name)
    has_content?(name)
  end

  def has_no_item?(name)
    has_no_content?(name)
  end

  private

  def category_section(category)
    find("h3", text: /\A#{Regexp.escape(category)}\z/).ancestor("div.mb-6")
  end

  def open_details
    details = find("details", visible: :all)
    return if details[:open]

    page.execute_script("arguments[0].setAttribute('open', '')", details)
  end

  def set_position_field
    page.execute_script(
      "var form = arguments[0];" \
      "var input = document.createElement('input');" \
      "input.type = 'hidden';" \
      "input.name = 'checklist_item[position]';" \
      "input.value = arguments[1];" \
      "form.appendChild(input);",
      find("form"),
      "2",
    )
  end
end
