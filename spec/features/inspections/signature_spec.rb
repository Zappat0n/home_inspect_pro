# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Digital signature", type: :feature do
  it "captures a signature and completes the inspection" do
    country = create(:country, code: "US", locale: "en")
    user = create(:user, country: country)
    inspection_template = create(:inspection_template, country: country, published: true)
    inspection = create(
      :inspection,
      user: user,
      inspection_template: inspection_template,
    )

    sign_in user

    page_obj = Inspections::SignaturePage.new(inspection)
    page_obj.visit_page

    expect(page_obj).to have_signature_pad_visible

    page_obj.set_signature
    page_obj.complete_inspection

    expect(page_obj).to have_signature_image
  end

  it "clears the signature before completing" do
    country = create(:country, code: "US", locale: "en")
    user = create(:user, country: country)
    inspection_template = create(:inspection_template, country: country, published: true)
    inspection = create(
      :inspection,
      user: user,
      inspection_template: inspection_template,
    )

    sign_in user

    page_obj = Inspections::SignaturePage.new(inspection)
    page_obj.visit_page

    expect(page_obj).to have_signature_pad_visible

    page_obj.set_signature
    page_obj.clear_signature
    page_obj.complete_inspection

    expect(page_obj).to have_no_signature_image
  end

  it "does not show signature image on a draft inspection without signature data" do
    country = create(:country, code: "US", locale: "en")
    user = create(:user, country: country)
    inspection_template = create(:inspection_template, country: country, published: true)
    inspection = create(
      :inspection,
      user: user,
      inspection_template: inspection_template,
    )

    sign_in user

    page_obj = Inspections::SignaturePage.new(inspection)
    page_obj.visit_page

    expect(page_obj).to have_signature_pad_visible
    expect(page_obj).to have_no_signature_image
  end
end
