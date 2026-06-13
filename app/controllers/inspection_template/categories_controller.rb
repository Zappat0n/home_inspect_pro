# frozen_string_literal: true

class InspectionTemplate::CategoriesController < ApplicationController
  before_action :require_subscription

  def create
    category = template.categories.build(name: category_params[:name])

    if category.save
      respond_to do |format|
        format.turbo_stream do
          render(
            turbo_stream: [
              turbo_stream.before(
                "new_group_form",
                partial: "inspection_template/items/category_section",
                locals: { template: template, category: category, items: [] },
              ),
              turbo_stream.replace(
                "new_group_form",
                partial: "inspection_template/items/new_group_form",
                locals: { template: template },
              ),
            ],
          )
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render(
            turbo_stream: turbo_stream.replace(
              "new_group_form",
              partial: "inspection_template/items/new_group_form",
              locals: { template: template },
            ),
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  def destroy
    category = template.categories.find(params[:id])
    category.destroy!

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
    categories_data = params.require(:categories)
    ReorderPositionService.new(template.categories, categories_data).call

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

  def category_params
    params.expect(inspection_template_category: [:name])
  end
end
