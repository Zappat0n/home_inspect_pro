# frozen_string_literal: true

class InspectionsController < ApplicationController
  def index
    inspections = current_user.inspections.newest_first
    render(
      locals: {
        inspections: inspections,
      },
    )
  end

  def show
    inspection = current_user.inspections.find(params[:id])
    inspection_items = inspection.inspection_items.joins(:checklist_item).order("checklist_items.position")

    render(
      locals: {
        inspection: inspection,
        inspection_items: inspection_items,
      },
    )
  end

  def new
    inspection = current_user.inspections.build(
      inspection_template: current_user.default_inspection_template,
    )
    render(
      locals: {
        inspection: inspection,
      },
    )
  end

  def create
    inspection = current_user.inspections.build(
      inspection_params.merge(
        inspection_template: current_user.default_inspection_template,
        status: :draft,
      ),
    )

    if inspection.save
      Inspections::InitializeChecklistService.new(inspection).call
      redirect_to(inspection, notice: t("inspections.create.success"))
    else
      render(
        :new,
        status: :unprocessable_content,
        locals: {
          inspection: inspection,
        },
      )
    end
  end

  def complete
    inspection = current_user.inspections.find(params[:id])

    if inspection.completed?
      redirect_to(inspection, alert: t("inspections.complete.already_completed"))
      return
    end

    inspection.update(
      status: :completed,
      completed_at: Time.current,
      signature_data: params.dig(:inspection, :signature_data).presence,
    )
    GeneratePdfReportJob.perform_later(inspection.id, pdf_base_url)
    redirect_to(inspection, notice: t("inspections.complete.success"))
  end

  def report
    inspection = current_user.inspections.find(params[:id])

    if inspection.pdf_url.present?
      redirect_to(inspection.pdf_url, allow_other_host: true)
    else
      GeneratePdfReportJob.perform_later(inspection.id, pdf_base_url)
      redirect_to(inspection, notice: t("inspections.report.generating"))
    end
  end

  private

  def pdf_base_url
    "#{request.protocol}#{request.host_with_port}"
  end

  def inspection_params
    params.expect(inspection: %i[property_address client_name client_email signature_data])
  end
end
