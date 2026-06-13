class ChangeChecklistItemCategoryDefault < ActiveRecord::Migration[8.1]
  def change
    ChecklistItem.where(category: [nil, ""]).update_all(category: "General")
    change_column_null :checklist_items, :category, false
    change_column_default :checklist_items, :category, from: nil, to: "General"
  end
end
