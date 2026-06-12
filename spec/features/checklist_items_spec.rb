# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ChecklistItems", type: :feature do
  describe "adding an item" do
    it "creates a new checklist item in an existing category" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country, name: "My Template")
      create(:checklist_item, inspection_template: template, name: "Existing item", category: "Safety")

      sign_in user

      edit_page = InspectionTemplates::EditPage.new
      edit_page.visit_page(template)
      expect(edit_page).to have_heading(template)

      edit_page.add_item("Safety", name: "Check wiring", description: "Inspect all wiring", severity: "critical")

      item = template.checklist_items.find_by(name: "Check wiring")
      expect(item).to be_present
      expect(item.description).to eq("Inspect all wiring")
      expect(item.severity).to eq("critical")

      edit_page.visit_page(template)
      expect(edit_page).to have_item("Check wiring")
    end
  end

  describe "editing an item" do
    it "updates a checklist item name" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country, name: "My Template")
      item = create(:checklist_item, inspection_template: template, name: "Old name", category: "Safety")

      sign_in user

      edit_page = InspectionTemplates::EditPage.new
      edit_page.visit_page(template)
      expect(edit_page).to have_heading(template)
      expect(edit_page).to have_item("Old name")

      edit_page.edit_item(item, new_name: "Updated name")

      item.reload
      expect(item.name).to eq("Updated name")

      edit_page.visit_page(template)
      expect(edit_page).to have_item("Updated name")
    end
  end

  describe "deleting an item" do
    it "removes a checklist item" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country, name: "My Template")
      item = create(:checklist_item, inspection_template: template, name: "Item to delete", category: "Safety")

      sign_in user

      edit_page = InspectionTemplates::EditPage.new
      edit_page.visit_page(template)
      expect(edit_page).to have_heading(template)
      expect(edit_page).to have_item("Item to delete")

      edit_page.delete_item(item)

      expect(ChecklistItem.find_by(id: item.id)).to be_nil

      edit_page.visit_page(template)
      expect(edit_page).to have_no_item("Item to delete")
    end
  end
end
