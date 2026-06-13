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

  def click_edit_item(item)
    within("##{dom_id(item)}") do
      click_on I18n.t("checklist_items.edit.button")
    end
  end

  def update_item_name(item, new_name)
    within("##{dom_id(item)}") do
      fill_in I18n.t("checklist_items.form.name"), with: new_name
      click_on I18n.t("checklist_items.form.submit")
    end
  end

  def cancel_edit_item(item)
    within("##{dom_id(item)}") do
      click_on I18n.t("checklist_items.form.cancel")
    end
  end

  def has_inline_form_visible?(item)
    has_css?("##{dom_id(item)} [data-inline-edit-target='form']:not(.hidden)", visible: :visible)
  end

  def has_inline_form_hidden?(item)
    has_no_css?("##{dom_id(item)} [data-inline-edit-target='form']:not(.hidden)", visible: :visible)
  end

  def open_add_item_form(category_name)
    within(category_section(category_name)) do
      find("summary", text: I18n.t("inspection_templates.edit.add_item")).click
    end
  end

  def cancel_add_item(category_name)
    within(category_section(category_name)) do
      click_on I18n.t("checklist_items.form.cancel")
    end
  end

  def has_add_item_form_open?(category_name)
    has_css?("details[id='add_item_details_#{category_name.parameterize}'][open]", visible: :all)
  end

  def has_add_item_form_closed?(category_name)
    has_no_css?("details[id='add_item_details_#{category_name.parameterize}'][open]", visible: :all)
  end

  def open_new_group_form
    find("#new_group_form summary", visible: :all).click
  end

  def fill_new_group_name(name)
    within("#new_group_form") do
      fill_in I18n.t("checklist_items.form.category"), with: name
    end
  end

  def create_group
    within("#new_group_form") do
      click_on I18n.t("inspection_templates.edit.create_group")
    end
  end

  def has_category?(category_name)
    has_css?("h3[data-category-handle]", text: /\A#{Regexp.escape(category_name)}\z/)
  end

  def has_no_category?(category_name)
    has_no_css?("h3[data-category-handle]", text: /\A#{Regexp.escape(category_name)}\z/)
  end

  def has_categories_in_order?(names)
    category_names = all("h3[data-category-handle]", visible: :all, wait: Capybara.default_max_wait_time).map(&:text)
    category_names == names
  end

  def has_new_group_form_closed?
    has_no_css?("#new_group_form[open]", visible: :all)
  end

  def reorder_categories(template, new_order)
    url = reorder_inspection_template_categories_path(template)

    page.execute_script(<<~JS)
      var xhr = new XMLHttpRequest();
      xhr.open('PATCH', '#{url}', false);
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.setRequestHeader('Accept', 'text/vnd.turbo-stream.html');
      xhr.send(JSON.stringify({ categories: #{new_order.map.with_index { |id, i| { id: id, position: i } }.to_json} }));
      Turbo.renderStreamMessage(xhr.responseText);
    JS
  end

  def has_item_form_error?
    has_css?(".field_with_errors")
  end

  private

  def category_section(category)
    find("h3", text: /\A#{Regexp.escape(category)}\z/).ancestor("div.mb-6")
  end
end
