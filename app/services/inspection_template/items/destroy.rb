# frozen_string_literal: true

class InspectionTemplate::Items::Destroy
  attr_reader :item, :position, :template

  def initialize(item)
    @item = item
    @position = item.position
    @template = item.inspection_template
  end

  def call
    item.class.transaction do
      item.destroy!
      shift_items_down
    end
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    false
  end

  private

  def shift_items_down
    ids = template
      .items
      .where(inspection_template_category: item.inspection_template_category)
      .where("position > ?", position)
      .pluck(:id)

    return if ids.empty?

    template.items.where(id: ids).update_all("position = -position")
    template.items.where(id: ids).update_all("position = -position - 1")
  end
end
