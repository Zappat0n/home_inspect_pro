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
    it "updates the template name" do
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
      show_page = InspectionTemplates::ShowPage.new
      expect(show_page).to have_heading(template)
      expect(show_page).to have_update_success_message
      expect(template.name).to eq("Updated Template")
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
end
