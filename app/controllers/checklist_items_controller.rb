# frozen_string_literal: true

class ChecklistItemsController < ApplicationController
  before_action :require_subscription

  def create
    item = template.checklist_items.new(item_params)

    if item.save
      respond_to do |format|
        format.turbo_stream do
          render(
            turbo_stream: turbo_stream.append(
              "checklist_items",
              partial: "checklist_items/checklist_item",
              locals: { item: item },
            ),
          )
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render(
            turbo_stream: turbo_stream.replace(
              "checklist_item_form",
              partial: "checklist_items/checklist_item_form",
              locals: { item: item, template: template },
            ),

            status: :unprocessable_content,
          )
        end
      end
    end
  end

  def update
    item = template.checklist_items.find(params[:id])

    if item.update(item_params)
      respond_to do |format|
        format.turbo_stream do
          render(
            turbo_stream: turbo_stream.replace(
              "checklist_item_#{item.id}",
              partial: "checklist_items/checklist_item",
              locals: { item: item },
            ),
          )
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render(
            turbo_stream: turbo_stream.replace(
              "checklist_item_form",
              partial: "checklist_items/checklist_item_form",
              locals: { item: item, template: template },
            ),
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  def destroy
    item = template.checklist_items.find(params[:id])
    item.destroy!

    respond_to do |format|
      format.turbo_stream do
        render(turbo_stream: turbo_stream.remove("checklist_item_#{item.id}"))
      end
    end
  end

  def reorder
    items_data = params.require(:items)

    ChecklistItem.transaction do
      item_ids = items_data.map { |item| item[:id] }
      template.checklist_items.where(id: item_ids).update_all("position = -position")
      template.checklist_items.upsert_all(items_data)
    end

    respond_to do |format|
      format.turbo_stream do
        render(
          turbo_stream: turbo_stream.replace(
            "checklist_items",
            partial: "checklist_items/reorder",
            locals: { template: template },
          ),
        )
      end
    end
  end

  private

  def template
    @_template ||= current_user.inspection_templates.custom_templates.find(params[:inspection_template_id])
  end

  def item_params
    params.expect(checklist_item: [:name, :description, :category, :severity, :position, :allows_photo])
  end
end
