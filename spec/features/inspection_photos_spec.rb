# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Inspection photos", type: :feature do
  def setup_checklist_item(allows_photo: true)
    country = create(:country, code: "US")
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
      allows_photo: allows_photo,
    )
    {
      country: country,
      user: user,
      inspection_template: inspection_template,
      category: category,
      checklist_item: checklist_item,
    }
  end

  it "shows add photo button for items with allows_photo on draft inspection" do
    setup = setup_checklist_item(allows_photo: true)
    inspection = create(
      :inspection,
      user: setup[:user],
      inspection_template: setup[:inspection_template],
      property_address: "123 Main St",
      client_name: "John Doe",
      client_email: "john@example.com",
    )
    inspection_item = create(
      :inspection_item,
      inspection: inspection,
      checklist_item: setup[:checklist_item],
    )

    sign_in setup[:user]

    page_obj = Inspections::ShowPage.new(inspection)
    page_obj.visit_page

    expect(page_obj).to have_heading
    expect(page_obj).to have_photo_upload_input(inspection_item)
  end

  it "does not show add photo button when allows_photo is false" do
    setup = setup_checklist_item(allows_photo: false)
    inspection = create(
      :inspection,
      user: setup[:user],
      inspection_template: setup[:inspection_template],
      property_address: "123 Main St",
      client_name: "John Doe",
      client_email: "john@example.com",
    )
    inspection_item = create(
      :inspection_item,
      inspection: inspection,
      checklist_item: setup[:checklist_item],
    )

    sign_in setup[:user]

    page_obj = Inspections::ShowPage.new(inspection)
    page_obj.visit_page

    expect(page_obj).to have_heading
    expect(page_obj).to have_no_photo_upload_input(inspection_item)
  end

  it "does not show add photo button on completed inspection" do
    setup = setup_checklist_item(allows_photo: true)
    inspection = create(
      :inspection,
      user: setup[:user],
      inspection_template: setup[:inspection_template],
      property_address: "123 Main St",
      client_name: "John Doe",
      client_email: "john@example.com",
      status: :completed,
    )
    inspection_item = create(
      :inspection_item,
      inspection: inspection,
      checklist_item: setup[:checklist_item],
    )

    sign_in setup[:user]

    page_obj = Inspections::ShowPage.new(inspection)
    page_obj.visit_page

    expect(page_obj).to have_heading
    expect(page_obj).to have_no_photo_upload_input(inspection_item)
  end

  it "shows thumbnail for existing photo" do
    setup = setup_checklist_item(allows_photo: true)
    inspection = create(
      :inspection,
      user: setup[:user],
      inspection_template: setup[:inspection_template],
      property_address: "123 Main St",
      client_name: "John Doe",
      client_email: "john@example.com",
    )
    create(
      :inspection_item,
      inspection: inspection,
      checklist_item: setup[:checklist_item],
    )
    photo = build(:inspection_photo, inspection: inspection, checklist_item: setup[:checklist_item])
    photo.photo.attach(
      io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
      filename: "test.jpg",
      content_type: "image/jpeg",
    )
    photo.save!

    sign_in setup[:user]

    page_obj = Inspections::ShowPage.new(inspection)
    page_obj.visit_page

    expect(page_obj).to have_heading
    expect(page_obj).to have_photo_thumbnail
    expect(page_obj).to have_photo_delete_button
  end

  it "deletes a photo" do
    setup = setup_checklist_item(allows_photo: true)
    inspection = create(
      :inspection,
      user: setup[:user],
      inspection_template: setup[:inspection_template],
      property_address: "123 Main St",
      client_name: "John Doe",
      client_email: "john@example.com",
    )
    create(
      :inspection_item,
      inspection: inspection,
      checklist_item: setup[:checklist_item],
    )
    photo = build(:inspection_photo, inspection: inspection, checklist_item: setup[:checklist_item])
    photo.photo.attach(
      io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
      filename: "test.jpg",
      content_type: "image/jpeg",
    )
    photo.save!

    sign_in setup[:user]

    page_obj = Inspections::ShowPage.new(inspection)
    page_obj.visit_page

    expect(page_obj).to have_heading
    expect(page_obj).to have_photo_thumbnail
    expect(page_obj).to have_photo_delete_button

    page_obj.click_photo_delete_button
    page_obj.visit_page

    expect(page_obj).to have_heading
    expect(page_obj).to have_no_photo_thumbnail
  end

  it "does not show delete button on completed inspection" do
    setup = setup_checklist_item(allows_photo: true)
    inspection = create(
      :inspection,
      user: setup[:user],
      inspection_template: setup[:inspection_template],
      property_address: "123 Main St",
      client_name: "John Doe",
      client_email: "john@example.com",
      status: :completed,
    )
    create(
      :inspection_item,
      inspection: inspection,
      checklist_item: setup[:checklist_item],
    )
    photo = build(:inspection_photo, inspection: inspection, checklist_item: setup[:checklist_item])
    photo.photo.attach(
      io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
      filename: "test.jpg",
      content_type: "image/jpeg",
    )
    photo.save!

    sign_in setup[:user]

    page_obj = Inspections::ShowPage.new(inspection)
    page_obj.visit_page

    expect(page_obj).to have_heading
    expect(page_obj).to have_photo_thumbnail
    expect(page_obj).to have_no_photo_delete_button
  end
end
