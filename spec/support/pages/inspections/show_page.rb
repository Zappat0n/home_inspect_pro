# frozen_string_literal: true

class Inspections::ShowPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

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
end
