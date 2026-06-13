# frozen_string_literal: true

require "rails_helper"

RSpec.describe "InspectionTemplates", type: :feature do
  describe "viewing templates" do
    it "shows system templates for your country" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      create(:inspection_template, name: "Standard Electrical", country: country, published: true)

      sign_in user

      index_page = InspectionTemplates::IndexPage.new
      index_page.visit_page

      expect(index_page).to have_system_template_section
      expect(index_page).to have_template_card("Standard Electrical")
    end

    it "does not show system templates from other countries" do
      us = create(:country, code: "US")
      canada = create(:country, code: "CA")
      user = create(:user, country: us)
      create(:inspection_template, name: "Canada Electrical", country: canada, published: true)

      sign_in user

      index_page = InspectionTemplates::IndexPage.new
      index_page.visit_page

      expect(index_page).to have_system_template_section
      expect(index_page).to have_no_template_card("Canada Electrical")
    end
  end

  describe "duplicating a template" do
    it "duplicates a system template as a custom template" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      template = create(:inspection_template, name: "Standard Electrical", country: country, published: true)
      create(:checklist_item, inspection_template: template, name: "Check wiring")

      sign_in user

      index_page = InspectionTemplates::IndexPage.new
      index_page.visit_page
      expect(index_page).to have_template_card("Standard Electrical")

      index_page.duplicate_template("Standard Electrical")

      expect(index_page).to have_duplicate_success_message
      expect(InspectionTemplate.custom_templates.find_by(name: "Copy of Standard Electrical")).to be_present
    end
  end

  describe "creating a custom template" do
    it "creates a new custom template" do
      country = create(:country, code: "US")
      user = create(:user, country: country)

      sign_in user

      index_page = InspectionTemplates::IndexPage.new
      index_page.visit_page
      index_page.click_new_template

      new_page = InspectionTemplates::NewPage.new
      expect(new_page).to have_heading
      new_page.fill_name("My Home Inspection")
      new_page.submit

      template = InspectionTemplate.custom_templates.find_by(name: "My Home Inspection")
      expect(template).to be_present

      show_page = InspectionTemplates::ShowPage.new
      expect(show_page).to have_heading(template)
      expect(show_page).to have_success_message

      index_page.visit_page
      expect(index_page).to have_my_templates_section
      expect(index_page).to have_template_card("My Home Inspection")
    end

    it "shows validation error when name is blank" do
      country = create(:country, code: "US")
      user = create(:user, country: country)

      sign_in user

      new_page = InspectionTemplates::NewPage.new
      new_page.visit_page
      expect(new_page).to have_heading

      new_page.submit

      expect(new_page).to have_error
      expect(new_page).to have_heading
    end
  end

  describe "editing a custom template" do
    it "updates the template name", :js do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, name: "My Template", user: user, country: country)

      sign_in user

      index_page = InspectionTemplates::IndexPage.new
      index_page.visit_page
      expect(index_page).to have_my_templates_section
      expect(index_page).to have_template_card("My Template")

      index_page.edit_template("My Template")

      edit_page = InspectionTemplates::EditPage.new
      expect(edit_page).to have_heading(template)
      edit_page.fill_name("Updated Template")
      edit_page.submit

      template.reload
      expect(template.name).to eq("Updated Template")
      expect(edit_page).to have_updated_name("Updated Template")
    end
  end

  describe "deleting a custom template" do
    it "deletes a custom template" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      create(:inspection_template, :custom, name: "My Template", user: user, country: country)

      sign_in user

      index_page = InspectionTemplates::IndexPage.new
      index_page.visit_page
      expect(index_page).to have_template_card("My Template")

      index_page.delete_template("My Template")

      expect(index_page).to have_destroy_success_message
      expect(index_page).to have_no_template_card("My Template")
    end
  end

  describe "viewing template show page" do
    it "displays categories with items, severity badges, and photo badges" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, name: "My Template", user: user, country: country)
      category = create(:inspection_template_category, name: "Roof", inspection_template: template, position: 1)
      create(
        :inspection_template_item,
        name: "Check shingles",
        inspection_template: template,
        inspection_template_category: category,
        severity: :major,
        allows_photo: true,
        position: 1,
      )
      create(
        :inspection_template_item,
        name: "Check flashing",
        inspection_template: template,
        inspection_template_category: category,
        severity: :info,
        allows_photo: false,
        position: 2,
      )
      sign_in user

      show_page = InspectionTemplates::ShowPage.new
      show_page.visit_page(template)

      expect(show_page).to have_heading(template)
      expect(show_page).to have_items_count(2)
      expect(show_page).to have_category("Roof")
      expect(show_page).to have_edit_link
      expect(show_page).to have_item_in_category("Roof", "Check shingles")
      expect(show_page).to have_item_in_category("Roof", "Check flashing")
    end

    it "does not show edit link for system or another user's custom template" do
      country = create(:country, code: "US")
      user_a = create(:user, country: country)
      user_b = create(:user, country: country)
      system_template = create(:inspection_template, name: "System Template", country: country, published: true)
      other_template = create(:inspection_template, :custom, name: "User B Template", user: user_b, country: country)
      sign_in user_a

      show_page = InspectionTemplates::ShowPage.new

      show_page.visit_page(system_template)
      expect(show_page).to have_no_edit_link

      show_page.visit_page(other_template)
      expect(show_page).to have_no_edit_link
    end
  end

  describe "editing template items and categories" do
    it "updates an item name via inline edit", :js do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, name: "My Template", user: user, country: country)
      category = create(:inspection_template_category, name: "Electrical", inspection_template: template, position: 1)
      item = create(
        :inspection_template_item,
        name: "Check wiring",
        inspection_template: template,
        inspection_template_category: category,
        position: 1,
      )

      sign_in user

      edit_page = InspectionTemplates::EditPage.new
      edit_page.visit_page(template)
      expect(edit_page).to have_heading(template)

      edit_page.click_edit_item(item)
      edit_page.update_item_name(item, "Verify grounding")

      expect(edit_page).to have_item("Verify grounding")
      expect(edit_page).to have_inline_form_hidden(item)

      item.reload
      expect(item.name).to eq("Verify grounding")
    end

    it "cancels add item form", :js do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, name: "My Template", user: user, country: country)
      category = create(:inspection_template_category, name: "Electrical", inspection_template: template, position: 1)

      sign_in user

      edit_page = InspectionTemplates::EditPage.new
      edit_page.visit_page(template)
      expect(edit_page).to have_heading(template)

      edit_page.open_add_item_form(category.name)
      expect(edit_page).to have_add_item_form_open("Electrical")

      edit_page.cancel_add_item(category.name)
      expect(edit_page).to have_add_item_form_closed("Electrical")
    end

    it "reorders categories", :js do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, name: "My Template", user: user, country: country)
      cat1 = create(:inspection_template_category, name: "Electrical", inspection_template: template, position: 1)
      cat2 = create(:inspection_template_category, name: "Plumbing", inspection_template: template, position: 2)

      sign_in user

      edit_page = InspectionTemplates::EditPage.new
      edit_page.visit_page(template)
      expect(edit_page).to have_heading(template)
      expect(edit_page).to have_categories_in_order(%w[Electrical Plumbing])

      edit_page.reorder_categories(template, [cat2.id, cat1.id])

      expect(edit_page).to have_categories_in_order(%w[Plumbing Electrical])

      cat1.reload
      cat2.reload
      expect(cat1.position).to be > cat2.position
    end

    it "creates a new category group", :js do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, name: "My Template", user: user, country: country)

      sign_in user

      edit_page = InspectionTemplates::EditPage.new
      edit_page.visit_page(template)
      expect(edit_page).to have_heading(template)

      edit_page.open_new_group_form
      edit_page.fill_new_group_name("Roofing")
      edit_page.create_group

      expect(edit_page).to have_category("Roofing")
      expect(edit_page).to have_new_group_form_closed

      new_category = template.categories.find_by(name: "Roofing")
      expect(new_category).to be_present
    end

    it "shows error when updating item with blank name", :js do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, name: "My Template", user: user, country: country)
      category = create(:inspection_template_category, name: "Electrical", inspection_template: template, position: 1)
      item = create(
        :inspection_template_item,
        name: "Check wiring",
        inspection_template: template,
        inspection_template_category: category,
        position: 1,
      )

      sign_in user

      edit_page = InspectionTemplates::EditPage.new
      edit_page.visit_page(template)
      expect(edit_page).to have_heading(template)

      edit_page.click_edit_item(item)
      edit_page.update_item_name(item, "")

      expect(edit_page).to have_inline_form_visible(item)
      expect(edit_page).to have_item_form_error

      item.reload
      expect(item.name).to eq("Check wiring")
    end
  end
end
