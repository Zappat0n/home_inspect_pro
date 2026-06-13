# frozen_string_literal: true

class ChecklistItems::Create
  attr_reader :item, :template, :category

  def initialize(item)
    @item = item
    @template = item.inspection_template
    @category = item.category
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
      .checklist_items
      .where("position >= ?", position)
      .pluck(:id)

    return if ids.empty?

    template.checklist_items.where(id: ids).update_all("position = -position")
    template.checklist_items.where(id: ids).update_all("position = -position + 1")
  end

  def position
    @_position ||= template
      .checklist_items
      .where(category: category)
      .maximum(:position)
      .to_i + 1
  end
end
