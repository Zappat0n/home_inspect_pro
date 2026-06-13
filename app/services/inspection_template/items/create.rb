# frozen_string_literal: true

class InspectionTemplate::Items::Create
  attr_reader :item, :template, :category

  def initialize(item)
    @item = item
    @template = item.inspection_template
    @category = item.inspection_template_category
  end

  def call
    item.class.transaction do
      shift_items_up
      item.position = position

      item.save!
    end
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    false
  end

  private

  def shift_items_up
    ids = template
      .items
      .where(inspection_template_category: category)
      .where("position >= ?", position)
      .pluck(:id)

    return if ids.empty?

    template.items.where(id: ids).update_all("position = -position")
    template.items.where(id: ids).update_all("position = -position + 1")
  end

  def position
    @_position ||= template
      .items
      .where(inspection_template_category: category)
      .maximum(:position)
      .to_i + 1
  end
end
