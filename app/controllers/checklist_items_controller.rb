# frozen_string_literal: true

class ChecklistItemsController < ApplicationController
  before_action :require_subscription

  def create
    item = template.checklist_items.new(item_params)

    if item.save
      render(json: { success: true, item: item }, status: :created)
    else
      render(json: { errors: item.errors.full_messages }, status: :unprocessable_content)
    end
  end

  def update
    item = template.checklist_items.find(params[:id])

    if item.update(item_params)
      render(json: { success: true, item: item })
    else
      render(json: { errors: item.errors.full_messages }, status: :unprocessable_content)
    end
  end

  def destroy
    item = template.checklist_items.find(params[:id])
    item.destroy!
    render(json: { success: true })
  end

  def reorder
    items_data = params.require(:items)

    ChecklistItem.transaction do
      item_ids = items_data.map { |item| item[:id] }
      template.checklist_items.where(id: item_ids).update_all("position = -position")
      template.checklist_items.upsert_all(items_data)
    end

    render(json: { success: true })
  end

  private

  def template
    @_template ||= current_user.inspection_templates.custom_templates.find(params[:inspection_template_id])
  end

  def item_params
    params.expect(checklist_item: [:name, :description, :category, :severity, :position, :allows_photo])
  end
end
