# frozen_string_literal: true

class InspectionItemsController < ApplicationController
  def update
    inspection = current_user.inspections.find(params[:inspection_id])
    inspection_item = inspection.inspection_items.find(params[:id])

    if inspection.completed?
      redirect_to(
        inspection,
        alert: t("inspection_items.update.completed_alert"),
      )
      return
    end

    if inspection_item.update(inspection_item_params)
      render_success(inspection_item, inspection)
    else
      render_error(inspection_item, inspection)
    end
  end

  private

  def render_success(inspection_item, inspection)
    render(
      formats: :turbo_stream,
      locals: {
        inspection_item: inspection_item,
        inspection: inspection,
      },
    )
  end

  def render_error(inspection_item, inspection)
    render(
      :update,
      formats: :turbo_stream,
      status: :unprocessable_content,
      locals: {
        inspection_item: inspection_item,
        inspection: inspection,
      },
    )
  end

  def inspection_item_params
    params.expect(inspection_item: %i[status comment])
  end
end
