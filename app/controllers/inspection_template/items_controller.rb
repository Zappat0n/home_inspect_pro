# frozen_string_literal: true

class InspectionTemplate::ItemsController < ApplicationController
  before_action :require_subscription

  def create
    item = template.items.new(item_params)

    if InspectionTemplate::Items::Create.new(item).call
      respond_to do |format|
        format.turbo_stream do
          render(
            turbo_stream: turbo_stream.replace(
              "checklist_items",
              partial: "inspection_template/items/reorder",
              locals: { template: template },
            ),
          )
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render(
            turbo_stream: turbo_stream.replace(
              "new_checklist_item_#{item.inspection_template_category.name.to_s.parameterize}",
              partial: "inspection_template/items/form",
              locals: { item: item, template: template, inline: false },
            ),
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  def update
    item = template.items.find(params[:id])

    if item.update(item_params)
      respond_to do |format|
        format.turbo_stream do
          render(
            turbo_stream: turbo_stream.replace(
              "checklist_item_#{item.id}",
              partial: "inspection_template/items/item",
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
              partial: "inspection_template/items/form",
              locals: { item: item, template: template, inline: true },
            ),
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  def destroy
    item = template.items.find(params[:id])

    InspectionTemplate::Items::Destroy.new(item).call

    respond_to do |format|
      format.turbo_stream do
        render(
          turbo_stream: turbo_stream.replace(
            "checklist_items",
            partial: "inspection_template/items/reorder",
            locals: { template: template },
          ),
        )
      end
    end
  end

  def reorder
    items_data = params.require(:items)

    InspectionTemplate::Item.transaction do
      item_ids = items_data.map { |item| item[:id] }
      items = template.items.where(id: item_ids)
      items.update_all("position = -position")

      # Include category_id for NOT NULL constraint in upsert
      item_categories = items.pluck(:id, :inspection_template_category_id).to_h
      items_with_keys = items_data.map do |item_data|
        {
          id: item_data[:id],
          position: item_data[:position],
          inspection_template_category_id: item_categories[item_data[:id].to_i],
        }
      end
      template.items.upsert_all(items_with_keys)
    end

    respond_to do |format|
      format.turbo_stream do
        render(
          turbo_stream: turbo_stream.replace(
            "checklist_items",
            partial: "inspection_template/items/reorder",
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
    params.expect(
      inspection_template_item: [:name,
                                 :description,
                                 :inspection_template_category_id,
                                 :severity,
                                 :position,
                                 :allows_photo,
      ],
    )
  end
end
