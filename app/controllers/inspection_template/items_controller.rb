# frozen_string_literal: true

class InspectionTemplate::ItemsController < ApplicationController
  include ActionView::RecordIdentifier

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
      render(
        turbo_stream: turbo_stream.replace(
          dom_id(item),
          partial: "inspection_template/items/item",
          locals: { item: item },
        ),
      )
    else
      render(
        turbo_stream: turbo_stream.replace(
          "#{dom_id(item)}_form",
          partial: "inspection_template/items/form",
          locals: { item: item, template: template, inline: true },
        ),
        status: :unprocessable_content,
      )
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
    ReorderPositionService.new(template.items, items_data).call

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
