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
      expect(find("[data-testid='inspection-item-ok-status']")).to be_visible
    end
  end

  def has_defect_status_selected?(item)
    within "##{dom_id(item)}" do
      expect(find("[data-testid='inspection-item-defect-status']")).to be_visible
    end
  end

  def has_na_status_selected?(item)
    within "##{dom_id(item)}" do
      expect(find("[data-testid='inspection-item-na-status']")).to be_visible
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
end
