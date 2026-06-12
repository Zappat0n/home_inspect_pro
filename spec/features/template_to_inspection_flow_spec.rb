# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Template to Inspection Flow", type: :feature do
  it "duplicates a system template, creates inspection, completes it, and generates PDF", :js do
    country = create(:country, code: "US", locale: "en")
    user = create(:user, country: country)
    system_template = create(
      :inspection_template,
      name: "Standard Electrical",
      country: country,
      published: true,
    )
    create(
      :checklist_item,
      inspection_template: system_template,
      category: "Safety",
      name: "Check wiring",
      position: 1,
    )
    create(:report_template, country: country, locale: "en")

    grover_double = instance_double(Grover, to_pdf: "fake pdf content")
    allow(Grover).to receive(:new).and_return(grover_double)

    sign_in user

    # Step 1: Duplicate system template (redirects to edit page)
    index_page = InspectionTemplates::IndexPage.new
    index_page.visit_page
    expect(index_page).to have_system_template_section
    expect(index_page).to have_template_card("Standard Electrical")

    index_page.duplicate_template("Standard Electrical")

    custom_template = InspectionTemplate.custom_templates.find_by!(name: "Copy of Standard Electrical")
    expect(custom_template).to be_present

    # Step 2: Add a checklist item on the edit page
    edit_page = InspectionTemplates::EditPage.new
    expect(edit_page).to have_heading(custom_template)
    expect(edit_page).to have_item("Check wiring")
    edit_page.add_item("Safety", name: "Fire Extinguisher")
    expect(edit_page).to have_item("Fire Extinguisher")

    # Step 3: Create an inspection with the custom template
    new_page = Inspections::NewPage.new
    new_page.visit_page
    expect(new_page).to have_heading
    new_page.select_template(custom_template)
    new_page.fill_in_with(
      property_address: "123 Main St",
      client_name: "Jane Doe",
      client_email: "jane@example.com",
    )
    new_page.submit

    inspection = Inspection.last
    expect(inspection.inspection_template).to eq(custom_template)

    show_page = Inspections::ShowPage.new
    expect(show_page).to have_heading
    expect(show_page).to have_success_message
    expect(show_page).to have_template_name(inspection)

    # Step 4: Mark inspection items
    inspection_items = inspection.inspection_items.to_a
    show_page.click_ok_status(inspection_items[0])
    expect(show_page).to have_ok_status_selected(inspection_items[0])
    show_page.click_defect_status(inspection_items[1])
    expect(show_page).to have_defect_status_selected(inspection_items[1])

    # Step 5: Complete the inspection with signature
    ActiveStorage::Current.url_options = { host: "http://localhost:3000" }
    signature_page = Inspections::SignaturePage.new(inspection)
    signature_page.open_complete_modal
    expect(signature_page).to have_disabled_complete_button
    signature_page.set_signature_with_js
    expect(signature_page).to have_enabled_complete_button
    signature_page.complete_inspection

    expect(signature_page).to have_signature_image
    expect(signature_page).to have_success_message

    # Verify PDF was generated
    GeneratePdfReportJob.new.perform(inspection.id, "http://localhost:3000")
    inspection.reload
    expect(inspection.pdf).to be_attached
    expect(inspection.pdf_url).to be_present
  end
end
