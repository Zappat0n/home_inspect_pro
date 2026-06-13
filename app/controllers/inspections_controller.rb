# frozen_string_literal: true

class InspectionsController < ApplicationController
  before_action :require_subscription, except: [:index, :show]

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
    inspection_items = inspection.inspection_items.joins(:checklist_item).order("inspection_template_items.position")

    render(
      locals: {
        inspection: inspection,
        inspection_items: inspection_items,
      },
    )
  end

  def new
    templates = current_user.available_templates
    inspection = current_user.inspections.build(
      inspection_template: current_user.default_inspection_template,
    )
    render(
      locals: {
        inspection: inspection,
        templates: templates,
      },
    )
  end

  def create
    template_id = params.dig(:inspection, :inspection_template_id)
    inspection_template = current_user.available_templates.find_by(id: template_id) ||
                          current_user.default_inspection_template

    inspection = current_user.inspections.build(
      inspection_params.merge(
        inspection_template: inspection_template,
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
          templates: current_user.available_templates,
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

  def send_report
    inspection = current_user.inspections.find(params[:id])

    unless inspection.completed?
      redirect_to(inspection, alert: t("inspections.send_report.not_completed"))
      return
    end

    ReportMailer.send_report(inspection).deliver_later
    redirect_to(inspection, notice: t("inspections.send_report.success"))
  end

  def preview_report
    inspection = current_user.inspections.find(params[:id])

    unless inspection.completed?
      redirect_to(inspection, alert: t("inspections.preview_report.not_completed"))
      return
    end

    if inspection.pdf_url.blank?
      redirect_to(inspection, notice: t("inspections.report.generating"))
      return
    end

    render(locals: { inspection: inspection })
  end

  private

  def pdf_base_url
    "#{request.protocol}#{request.host_with_port}"
  end

  def inspection_params
    params.expect(inspection: %i[property_address client_name client_email signature_data])
  end
end
