# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Inspection items", type: :feature do
  it "shows comment with auto-save for defect item on draft inspection" do
    country = create(:country, code: "US", locale: "en")
    user = create(:user, country: country)
    inspection_template = create(:inspection_template, country: country, published: true)
    category = create(:inspection_template_category, inspection_template: inspection_template, name: "Roof")
    checklist_item = create(
      :checklist_item,
      inspection_template: inspection_template,
      inspection_template_category: category,
      name: "Shingles",
      description: "Check shingles condition",
      position: 1,
    )
    inspection = create(
      :inspection,
      user: user,
      inspection_template: inspection_template,
      property_address: "123 Main St",
      client_name: "John Doe",
      client_email: "john@example.com",
    )
    inspection_item = create(
      :inspection_item,
      inspection: inspection,
      checklist_item: checklist_item,
      status: :defect,
      comment: nil,
    )

    sign_in user

    page_obj = Inspections::ShowPage.new(inspection)
    page_obj.visit_page

    expect(page_obj).to have_heading

    expect(page_obj).to have_category("Roof")
    expect(page_obj).to have_inspection_item(inspection_item)

    expect(page_obj).to have_comment_visible(inspection_item)
    expect(page_obj).to have_auto_save_form(inspection_item)

    page_obj.fill_in_comment(inspection_item, "Missing shingles on north slope")

    expect(page_obj).to have_comment_visible(inspection_item)
    expect(page_obj).to have_auto_save_form(inspection_item)
  end

  it "disables comment textarea when inspection is completed" do
    country = create(:country, code: "US", locale: "en")
    user = create(:user, country: country)
    inspection_template = create(:inspection_template, country: country, published: true)
    category = create(:inspection_template_category, inspection_template: inspection_template, name: "Roof")
    checklist_item = create(
      :checklist_item,
      inspection_template: inspection_template,
      inspection_template_category: category,
      name: "Shingles",
      description: "Check shingles condition",
      position: 1,
    )
    inspection = create(
      :inspection,
      user: user,
      inspection_template: inspection_template,
      status: :completed,
    )
    inspection_item = create(
      :inspection_item,
      inspection: inspection,
      checklist_item: checklist_item,
      status: :defect,
      comment: "Existing defect",
    )

    sign_in user

    page_obj = Inspections::ShowPage.new(inspection)
    page_obj.visit_page

    expect(page_obj).to have_heading

    expect(page_obj).to have_comment_visible(inspection_item)
    expect(page_obj).to have_comment_disabled(inspection_item)
  end
end
