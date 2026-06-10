# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Offline form queue", :js, type: :feature do
  describe "offline behavior" do
    it "shows and hides the offline banner" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      inspection_template = create(:inspection_template, country: country, published: true)
      create(:checklist_item, inspection_template: inspection_template)
      inspection = create(
        :inspection,
        user: user,
        inspection_template: inspection_template,
      )

      sign_in user

      page_obj = Inspections::ShowPage.new(inspection)
      page_obj.visit_page

      expect(page_obj).to have_heading

      page.driver.browser.network.offline_mode

      expect(page_obj).to have_offline_banner

      page_obj.dismiss_offline_banner

      expect(page_obj).to have_no_offline_banner
    end

    it "updates both items after offline queue and replay" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      inspection_template = create(:inspection_template, country: country, published: true)
      checklist_item_1 = create(:checklist_item, inspection_template: inspection_template, name: "Item 1", position: 1)
      checklist_item_2 = create(:checklist_item, inspection_template: inspection_template, name: "Item 2", position: 2)
      inspection = create(
        :inspection,
        user: user,
        inspection_template: inspection_template,
      )
      inspection_item_1 = create(
        :inspection_item,
        inspection: inspection,
        checklist_item: checklist_item_1,
        status: :ok,
      )
      inspection_item_2 = create(
        :inspection_item,
        inspection: inspection,
        checklist_item: checklist_item_2,
        status: :ok,
      )

      sign_in user

      page_obj = Inspections::ShowPage.new(inspection)
      page_obj.visit_page

      expect(page_obj).to have_heading

      page.driver.browser.network.offline_mode

      expect(page_obj).to have_offline_banner

      page_obj.click_defect_status(inspection_item_1)

      page_obj.click_na_status(inspection_item_2)

      queue_json = page.evaluate_script("localStorage.getItem('offline-form-queue')")
      queue = JSON.parse(queue_json)

      expect(queue).to be_an(Array)
      expect(queue.length).to eq(2)

      online_event = "window.dispatchEvent(new CustomEvent('offline:status-change', { detail: { online: true } }))"
      page.driver.browser.network.emulate_network_conditions(offline: false)
      page.execute_script(online_event)
      sleep 0.3

      inspection_item_1.reload
      inspection_item_2.reload
      expect(inspection_item_1.status).to eq("defect")
      expect(inspection_item_2.status).to eq("na")

      queue_json = page.evaluate_script("localStorage.getItem('offline-form-queue')")
      queue = queue_json ? JSON.parse(queue_json) : []
      expect(queue).to be_empty
    end
  end
end
