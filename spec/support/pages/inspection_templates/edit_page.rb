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
    has_css?(
      "[data-testid='edit-template-heading']",
      text: I18n.t("inspection_templates.edit.title", name: template.name),
    )
  end

  def has_create_success_message?
    has_css?("[data-testid='flash-notice']", text: I18n.t("inspection_templates.create.success"))
  end

  def has_error?
    has_css?("[data-testid='template-form-errors']")
  end

  def add_item(category, name:, description: "", severity: "info")
    within(category_section(category)) do
      page.execute_script(
        "arguments[0].setAttribute('open', '')",
        find("[data-testid='add-item-details']", visible: :all),
      )
      within("[data-testid='add-item-details']") do
        find("[data-testid='checklist-item-name-input']").set(name)
        find("[data-testid='checklist-item-description-input']").set(description)
        find("[data-testid='checklist-item-severity-select']").find("option[value='#{severity}']").select_option
        find("[data-testid='checklist-item-submit']").click
      end
    end
  end

  def edit_item(item, new_name:)
    within("##{dom_id(item)}") do
      page.execute_script(
        "arguments[0].classList.remove('hidden')",
        find("[data-testid='inline-edit-form']", visible: :all),
      )
      find("[data-testid='checklist-item-name-input']").set(new_name)
      find("[data-testid='checklist-item-submit']").click
    end
  end

  def delete_item(item)
    within("##{dom_id(item)}") do
      page.accept_confirm do
        find("[data-testid='item-delete-button']").click
      end
    end
  end

  def has_item?(name)
    has_css?("[data-testid='item-name']", text: name)
  end

  def has_no_item?(name)
    has_no_css?("[data-testid='item-name']", text: name)
  end

  def has_updated_name?(name)
    has_css?("[data-testid='template-name-input'][value='#{name}']")
  end

  def click_edit_item(item)
    within("##{dom_id(item)}") do
      find("[data-testid='item-edit-button']").click
    end
  end

  def update_item_name(item, new_name)
    within("##{dom_id(item)}") do
      find("[data-testid='checklist-item-name-input']").set(new_name)
      find("[data-testid='checklist-item-submit']").click
    end
  end

  def cancel_edit_item(item)
    within("##{dom_id(item)}") do
      find("[data-testid='checklist-item-cancel']").click
    end
  end

  def has_inline_form_visible?(item)
    has_css?("##{dom_id(item)} [data-testid='inline-edit-form']", visible: :visible)
  end

  def has_inline_form_hidden?(item)
    has_no_css?("##{dom_id(item)} [data-testid='inline-edit-form']", visible: :visible)
  end

  def open_add_item_form(category_name)
    within(category_section(category_name)) do
      find("[data-testid='add-item-summary']", text: I18n.t("inspection_templates.edit.add_item")).click
    end
  end

  def cancel_add_item(category_name)
    within(category_section(category_name)) do
      find("[data-testid='checklist-item-cancel']").click
    end
  end

  def has_add_item_form_open?(category_name)
    has_css?(
      "[data-testid='add-item-details'][data-category-name='#{category_name.parameterize}'][open]",
      visible: :all,
    )
  end

  def has_add_item_form_closed?(category_name)
    has_no_css?(
      "[data-testid='add-item-details'][data-category-name='#{category_name.parameterize}'][open]",
      visible: :all,
    )
  end

  def open_new_group_form
    find("[data-testid='new-group-summary']", visible: :all).click
  end

  def fill_new_group_name(name)
    within("[data-testid='new-group-form']") do
      find("[data-testid='new-group-name-input']").set(name)
    end
  end

  def create_group
    within("[data-testid='new-group-form']") do
      find("[data-testid='new-group-submit']").click
    end
  end

  def has_category?(category_name)
    has_css?("[data-testid='category-heading']", text: /\A#{Regexp.escape(category_name)}\z/)
  end

  def has_no_category?(category_name)
    has_no_css?("[data-testid='category-heading']", text: /\A#{Regexp.escape(category_name)}\z/)
  end

  def has_categories_in_order?(names)
    page.document.synchronize do
      category_names = all("[data-testid='category-heading']", visible: :all).map(&:text)
      raise Capybara::ExpectationNotMet unless category_names == names
    end
    true
  rescue Capybara::ExpectationNotMet
    false
  end

  def has_new_group_form_closed?
    has_no_css?("[data-testid='new-group-form'][open]", visible: :all)
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
    has_css?("[data-testid='item-form-errors']")
  end

  private

  def category_section(category)
    find(
      "[data-testid='category-heading']",
      text: /\A#{Regexp.escape(category)}\z/,
    ).ancestor("[data-testid='category-section']")
  end
end
