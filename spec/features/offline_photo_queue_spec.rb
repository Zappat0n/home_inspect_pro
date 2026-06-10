# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Offline photo upload queue", :js, type: :feature do
  describe "offline photo behavior" do
    it "queues photo offline, uploads when online, and persists to DB" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      inspection_template = create(:inspection_template, country: country, published: true)
      checklist_item = create(:checklist_item, inspection_template: inspection_template, allows_photo: true)
      inspection = create(:inspection, user: user, inspection_template: inspection_template)
      inspection_item = create(:inspection_item, inspection: inspection, checklist_item: checklist_item)

      photo_path = Rails.root.join("tmp/test_photo.png")
      File.open(photo_path, "wb") do |f|
        f.write(
          Base64.decode64(
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAA" \
            "AABJRU5ErkJggg==",
          ),
        )
      end

      sign_in user

      page_obj = Inspections::ShowPage.new(inspection)
      page_obj.visit_page

      expect(page_obj).to have_heading

      page.driver.browser.network.offline_mode

      expect(page_obj).to have_offline_banner

      page_obj.upload_photo(inspection_item, photo_path)
      page_obj.wait_for_queued_photo

      expect(page_obj).to have_queued_photo
      expect(page_obj.queued_photo_count).to eq(1)
      expect(page_obj.queued_photo_file_name).to eq("test_photo.png")
      expect(page_obj).to have_indexeddb_photo

      online_event = "window.dispatchEvent(new CustomEvent('offline:status-change', { detail: { online: true } }))"
      page.driver.browser.network.emulate_network_conditions(offline: false)
      page.execute_script(online_event)

      page_obj.wait_for_photo_in_db(inspection)

      page_obj.visit_page
      expect(page_obj).to have_heading
      expect(page_obj).to have_photo_thumbnail

      expect(inspection.inspection_photos.count).to eq(1)

      page_obj.wait_for_no_indexeddb_photos

      expect(page_obj).to have_empty_offline_queue
      expect(page_obj).to have_no_indexeddb_photos
    end
  end
end
