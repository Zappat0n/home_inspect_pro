# frozen_string_literal: true

class Inspections::SignaturePage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  SIGNATURE_VALUE = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk" \
                    "+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="

  attr_reader :inspection

  def initialize(inspection = nil)
    @inspection = inspection
  end

  def visit_page
    visit inspection_path(inspection)
  end

  def set_signature(value = SIGNATURE_VALUE)
    find("[data-signature-pad-target='signatureInput']", visible: false).set(value)
  end

  def has_signature_pad?
    has_css?("[data-signature-pad-target='canvas']")
  end

  def has_signature_image?
    has_css?("img[alt='#{I18n.t('inspections.show.signature_alt')}']")
  end

  def clear_signature
    find("[data-testid='clear-signature-button']").click
    find("[data-signature-pad-target='signatureInput']", visible: false).set("")
  end

  def complete_inspection
    find("[data-testid='complete-inspection-button']").click
  end

  def has_signature_pad_visible?
    has_css?("[data-signature-pad-target='canvas']", visible: true)
  end

  def has_no_signature_image?
    has_no_css?("img[alt='#{I18n.t('inspections.show.signature_alt')}']")
  end

  def has_success_message?
    has_content?(I18n.t("inspections.complete.success"))
  end
end
