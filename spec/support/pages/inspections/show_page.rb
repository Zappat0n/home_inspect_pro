# frozen_string_literal: true

class Inspections::ShowPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include ActionView::RecordIdentifier

  def initialize(inspection = nil)
    @inspection = inspection
  end

  def visit_page
    visit inspection_path(@inspection)
  end

  def has_heading?
    has_content?(I18n.t("inspections.show.title"))
  end

  def has_property_address?(inspection)
    has_content?(inspection.property_address)
  end

  def has_client_name?(inspection)
    has_content?(inspection.client_name)
  end

  def has_client_email?(inspection)
    has_content?(inspection.client_email)
  end

  def has_template_name?(inspection)
    has_content?(inspection.inspection_template.name)
  end

  def has_draft_status?
    has_content?(I18n.t("inspections.show.statuses.draft"))
  end

  def has_success_message?
    has_content?(I18n.t("inspections.create.success"))
  end

  def has_category?(category)
    has_content?(category)
  end

  def has_inspection_item?(item)
    has_content?(item.checklist_item.name)
  end

  def click_ok_status(item)
    within "##{dom_id(item)}" do
      find("[data-testid='inspection-item-ok-status']").click
    end
  end

  def click_defect_status(item)
    within "##{dom_id(item)}" do
      find("[data-testid='inspection-item-defect-status']").click
    end
  end

  def click_na_status(item)
    within "##{dom_id(item)}" do
      find("[data-testid='inspection-item-na-status']").click
    end
  end

  def has_ok_status_selected?(item)
    within "##{dom_id(item)}" do
      button = find("[data-testid='inspection-item-ok-status']")
      button[:class].include?("bg-green-600")
    end
  end

  def has_defect_status_selected?(item)
    within "##{dom_id(item)}" do
      button = find("[data-testid='inspection-item-defect-status']")
      button[:class].include?("bg-red-600")
    end
  end

  def has_na_status_selected?(item)
    within "##{dom_id(item)}" do
      button = find("[data-testid='inspection-item-na-status']")
      button[:class].include?("bg-yellow-600")
    end
  end

  def has_update_success_message?
    has_content?(I18n.t("inspection_items.update.success"))
  end

  def has_completed_alert?
    has_content?(I18n.t("inspection_items.update.completed_alert"))
  end

  def fill_in_comment(item, comment_text)
    within "##{dom_id(item)}" do
      find("[data-testid='inspection-item-comment-textarea']").fill_in(with: comment_text)
    end
  end

  def has_comment_visible?(item)
    within "##{dom_id(item)}" do
      has_css?("[data-testid='inspection-item-comment-textarea']", visible: true)
    end
  end

  def has_comment_hidden?(item)
    within "##{dom_id(item)}" do
      has_no_css?("[data-testid='inspection-item-comment-textarea']", visible: true)
    end
  end

  def has_no_comment_visible?
    has_no_css?("[data-testid='inspection-item-comment-textarea']", visible: true)
  end

  def has_auto_save_form?(item)
    within "##{dom_id(item)}" do
      has_css?("form[data-inspection-item-target='commentForm']") &&
        has_css?("[data-testid='inspection-item-comment-textarea'][data-action='blur->inspection-item#saveComment']")
    end
  end

  def has_comment_disabled?(item)
    within "##{dom_id(item)}" do
      has_css?("[data-testid='inspection-item-comment-textarea'][disabled]")
    end
  end

  def click_complete_inspection
    find("[data-testid='complete-inspection-button']").click
  end

  def has_complete_button?
    has_css?("[data-testid='complete-inspection-button']")
  end

  def has_no_complete_button?
    has_no_css?("[data-testid='complete-inspection-button']")
  end

  def has_completed_status?
    has_content?(I18n.t("inspections.show.statuses.completed"))
  end

  def has_complete_success_message?
    has_content?(I18n.t("inspections.complete.success"))
  end

  def has_photo_upload_input?(item)
    within "##{dom_id(item)}" do
      has_css?("[data-testid='photo-upload-input']")
    end
  end

  def has_no_photo_upload_input?(item)
    within "##{dom_id(item)}" do
      has_no_css?("[data-testid='photo-upload-input']")
    end
  end

  def has_photo_thumbnail?
    has_css?("[data-testid='photo-thumbnail']")
  end

  def has_no_photo_thumbnail?
    has_no_css?("[data-testid='photo-thumbnail']")
  end

  def has_photo_delete_button?
    has_css?("[data-testid='photo-delete-button']")
  end

  def has_no_photo_delete_button?
    has_no_css?("[data-testid='photo-delete-button']")
  end

  def click_photo_delete_button
    find("[data-testid='photo-delete-button']").click
  end

  def attach_photo(item, file_path)
    within "##{dom_id(item)}" do
      attach_file("photo", file_path, make_visible: true)
    end
  end

  def has_offline_banner?
    has_css?("[data-offline-indicator-target='banner']", visible: true)
  end

  def has_no_offline_banner?
    has_no_css?("[data-offline-indicator-target='banner']", visible: true)
  end

  def dismiss_offline_banner
    find("[data-action='click->offline-indicator#dismiss']").trigger("click")
  end
end
