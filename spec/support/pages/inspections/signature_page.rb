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

  def set_signature_with_js(value = SIGNATURE_VALUE)
    page.execute_script(
      <<~JS,
        var input = document.querySelector("[data-signature-pad-target='signatureInput']");
        if (input) {
          input.value = arguments[0];
          var submitBtn = document.querySelector("[data-testid='complete-inspection-button']");
          if (submitBtn) submitBtn.disabled = false;
        }
      JS
      value,
    )
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

  def open_complete_modal
    find("[data-testid='open-complete-modal-button']").click
  end

  def has_open_complete_button?
    has_css?("[data-testid='open-complete-modal-button']")
  end

  def has_modal_visible?
    has_css?("[data-testid='complete-inspection-modal']", visible: true)
  end

  def cancel_complete
    first("[data-testid='cancel-complete-button']").click
  end

  def has_signature_pad_visible?
    has_css?("[data-signature-pad-target='canvas']", visible: true)
  end

  def has_no_signature_image?
    has_no_css?("img[alt='#{I18n.t('inspections.show.signature_alt')}']")
  end

  def has_disabled_complete_button?
    button = find("[data-testid='complete-inspection-button']")
    button.disabled?
  end

  def has_enabled_complete_button?
    button = find("[data-testid='complete-inspection-button']")
    !button.disabled?
  end

  def has_success_message?
    has_content?(I18n.t("inspections.complete.success"))
  end
end
