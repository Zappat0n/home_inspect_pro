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
    render(
      locals: {
        inspection: inspection,
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

  private

  def inspection_params
    params.expect(inspection: %i[property_address client_name client_email])
  end
end
