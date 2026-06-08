# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Inspection items", type: :feature do
  it "marks an item as defect and adds a comment" do
    country = create(:country, code: "US", locale: "en")
    user = create(:user, country: country)
    inspection_template = create(:inspection_template, country: country, published: true)
    checklist_item = create(
      :checklist_item,
      inspection_template: inspection_template,
      category: "Roof",
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
      status: :ok,
      comment: nil,
    )

    sign_in user

    page = Inspections::ShowPage.new(inspection)
    page.visit_page

    page.has_category?("Roof")

    page.has_inspection_item?(inspection_item)

    page.has_comment_hidden?(inspection_item)

    page.click_defect_status(inspection_item)

    page.has_comment_visible?(inspection_item)

    page.fill_in_comment(inspection_item, "Missing shingles on north slope")

    page.has_no_comment_visible?
  end
end
