# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Digital signature", type: :feature do
  it "disables submit without signature and enables it when signature is present", :js do
    country = create(:country, code: "US", locale: "en")
    user = create(:user, country: country)
    inspection_template = create(:inspection_template, country: country, published: true)
    inspection = create(
      :inspection,
      user: user,
      inspection_template: inspection_template,
    )

    create(:report_template, country: country, locale: "en")
    grover_double = instance_double(Grover, to_pdf: "fake pdf content")
    allow(Grover).to receive(:new).and_return(grover_double)
    allow(ActiveStorage::Current).to receive(:url_options).and_return({ host: "http://localhost:3000" })

    sign_in user

    page_obj = Inspections::SignaturePage.new(inspection)
    page_obj.visit_page

    expect(page_obj).to have_open_complete_button
    page_obj.open_complete_modal
    expect(page_obj).to have_signature_pad_visible

    # No signature yet — button should be disabled
    expect(page_obj).to have_disabled_complete_button

    # Set signature — button should become enabled
    page_obj.set_signature_with_js
    expect(page_obj).to have_enabled_complete_button

    # Clear signature — button should become disabled again
    page_obj.clear_signature
    expect(page_obj).to have_disabled_complete_button

    # Set signature again — button should become enabled
    page_obj.set_signature_with_js
    expect(page_obj).to have_enabled_complete_button

    # Complete the inspection
    page_obj.complete_inspection
    expect(page_obj).to have_signature_image
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

    expect(page_obj).to have_open_complete_button
    expect(page_obj).to have_no_signature_image
  end
end
