# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Inspections", type: :feature do
  describe "viewing the index" do
    it "shows empty state when user has no inspections" do
      country = create(:country, code: "US")
      user = create(:user, country: country)

      sign_in_page = SignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(user.email, "password123")
      sign_in_page.submit

      index_page = Inspections::IndexPage.new
      index_page.visit_page

      expect(index_page).to have_heading
      expect(index_page).to have_empty_state
    end

    it "lists the users inspections" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      template = create(:inspection_template, country: country, published: true)
      inspection = create(:inspection, user: user, inspection_template: template)

      sign_in_page = SignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(user.email, "password123")
      sign_in_page.submit

      index_page = Inspections::IndexPage.new
      index_page.visit_page

      expect(index_page).to have_heading
      expect(index_page).to have_inspection_listed(inspection)
    end
  end

  describe "creating an inspection" do
    it "creates and shows the new inspection" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      create(:inspection_template, country: country, published: true)

      sign_in_page = SignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(user.email, "password123")
      sign_in_page.submit

      index_page = Inspections::IndexPage.new
      index_page.visit_page
      index_page.click_new_inspection

      new_page = Inspections::NewPage.new
      expect(new_page).to have_heading
      new_page.fill_in_with(
        property_address: "123 Main St",
        client_name: "Jane Doe",
        client_email: "jane@example.com",
      )
      new_page.submit

      inspection = Inspection.last
      show_page = Inspections::ShowPage.new
      expect(show_page).to have_heading
      expect(show_page).to have_success_message
      expect(show_page).to have_property_address(inspection)
      expect(show_page).to have_client_name(inspection)
      expect(show_page).to have_client_email(inspection)
      expect(show_page).to have_template_name(inspection)
      expect(show_page).to have_draft_status
    end

    it "shows validation errors when form is blank" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      create(:inspection_template, country: country, published: true)

      sign_in_page = SignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(user.email, "password123")
      sign_in_page.submit

      index_page = Inspections::IndexPage.new
      index_page.visit_page
      index_page.click_new_inspection

      new_page = Inspections::NewPage.new
      expect(new_page).to have_heading
      new_page.submit

      expect(new_page).to have_validation_error
      expect(new_page).to have_heading
    end
  end

  describe "navigating the form" do
    it "cancels and returns to index" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      create(:inspection_template, country: country, published: true)

      sign_in_page = SignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(user.email, "password123")
      sign_in_page.submit

      new_page = Inspections::NewPage.new
      new_page.visit_page
      expect(new_page).to have_heading
      new_page.cancel

      index_page = Inspections::IndexPage.new
      expect(index_page).to have_heading
      expect(index_page).to have_empty_state
    end
  end

  describe "template selection" do
    it "shows template selector with system template" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      template = create(:inspection_template, country: country, published: true)

      sign_in_page = SignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(user.email, "password123")
      sign_in_page.submit

      new_page = Inspections::NewPage.new
      new_page.visit_page
      expect(new_page).to have_heading
      expect(new_page).to have_template_selector
      expect(new_page).to have_template_card(template)
      expect(new_page).to have_no_custom_badge
    end

    it "shows custom template badge for custom templates" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      create(:inspection_template, country: country, published: true, name: "Standard")
      custom_template = create(:inspection_template, :custom, user: user, name: "My Custom", published: true)

      sign_in_page = SignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(user.email, "password123")
      sign_in_page.submit

      new_page = Inspections::NewPage.new
      new_page.visit_page
      expect(new_page).to have_heading
      expect(new_page).to have_template_selector
      expect(new_page).to have_template_card(custom_template)
      expect(new_page).to have_custom_badge
    end

    it "creates inspection with selected system template" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      template = create(:inspection_template, country: country, published: true, name: "Electrical")

      sign_in_page = SignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(user.email, "password123")
      sign_in_page.submit

      new_page = Inspections::NewPage.new
      new_page.visit_page
      expect(new_page).to have_heading
      new_page.select_template(template)
      new_page.fill_in_with(
        property_address: "456 Oak Ave",
        client_name: "Bob Smith",
        client_email: "bob@example.com",
      )
      new_page.submit

      inspection = Inspection.last
      show_page = Inspections::ShowPage.new
      expect(show_page).to have_heading
      expect(show_page).to have_success_message
      expect(inspection.inspection_template).to eq(template)
    end

    it "creates inspection with selected custom template" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      create(:inspection_template, country: country, published: true, name: "Standard")
      custom_template = create(:inspection_template, :custom, user: user, name: "My Custom", published: true)

      sign_in_page = SignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(user.email, "password123")
      sign_in_page.submit

      new_page = Inspections::NewPage.new
      new_page.visit_page
      expect(new_page).to have_heading
      new_page.select_template(custom_template)
      new_page.fill_in_with(
        property_address: "789 Pine Rd",
        client_name: "Alice Jones",
        client_email: "alice@example.com",
      )
      new_page.submit

      inspection = Inspection.last
      show_page = Inspections::ShowPage.new
      expect(show_page).to have_heading
      expect(show_page).to have_success_message
      expect(inspection.inspection_template).to eq(custom_template)
    end
  end

  describe "completing an inspection" do
    it "completes a draft inspection" do
      country = create(:country, code: "US", locale: "en")
      user = create(:user, country: country)
      inspection_template = create(:inspection_template, country: country, published: true)
      inspection = create(
        :inspection,
        user: user,
        inspection_template: inspection_template,
        property_address: "123 Main St",
        client_name: "John Doe",
        client_email: "john@example.com",
      )

      create(:report_template, country: country, locale: "en")
      allow(GeneratePdfReportJob).to receive(:perform_later)

      sign_in user

      page_obj = Inspections::ShowPage.new(inspection)
      page_obj.visit_page

      expect(page_obj).to have_heading
      expect(page_obj).to have_complete_button

      page_obj.click_complete_inspection

      expect(page_obj).to have_completed_status
      expect(page_obj).to have_complete_success_message
      expect(page_obj).to have_no_complete_button
    end

    it "does not show complete button on completed inspection" do
      country = create(:country, code: "US", locale: "en")
      user = create(:user, country: country)
      inspection_template = create(:inspection_template, country: country, published: true)
      inspection = create(
        :inspection,
        user: user,
        inspection_template: inspection_template,
        status: :completed,
      )

      sign_in user

      page_obj = Inspections::ShowPage.new(inspection)
      page_obj.visit_page

      expect(page_obj).to have_heading
      expect(page_obj).to have_no_complete_button
    end
  end
end
