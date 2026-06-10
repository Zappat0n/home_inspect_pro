# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PWA install banner", type: :feature do
  it "displays hidden install banner on the home page with correct content and buttons" do
    country = create(:country, code: "US", locale: "en")
    user = create(:user, country: country)

    sign_in user

    page_obj = PwaInstallBannerPage.new
    page_obj.visit_home

    expect(page_obj).to have_banner
    expect(page_obj).to have_banner_hidden
    expect(page_obj).to have_install_title
    expect(page_obj).to have_install_subtitle
    expect(page_obj).to have_install_button_text
    expect(page_obj).to have_install_button
    expect(page_obj).to have_dismiss_button
  end

  it "displays the banner on inspection show pages" do
    country = create(:country, code: "US", locale: "en")
    user = create(:user, country: country)
    inspection_template = create(:inspection_template, country: country, published: true)
    inspection = create(:inspection, user: user, inspection_template: inspection_template)

    sign_in user

    page_obj = PwaInstallBannerPage.new
    page_obj.visit_inspection(inspection)

    expect(page_obj).to have_banner
    expect(page_obj).to have_banner_hidden
  end
end
