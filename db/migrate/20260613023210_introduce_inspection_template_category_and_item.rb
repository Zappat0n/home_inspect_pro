# frozen_string_literal: true

class IntroduceInspectionTemplateCategoryAndItem < ActiveRecord::Migration[8.1]
  # Inline model classes for backfill — don't depend on app/models
  class ChecklistItem < ActiveRecord::Base
    self.table_name = "checklist_items"
  end

  class InspectionTemplateCategory < ActiveRecord::Base
    self.table_name = "inspection_template_categories"
  end

  def up
    # 1. Create inspection_template_categories table
    create_table :inspection_template_categories do |t|
      t.references :inspection_template, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position
      t.timestamps
    end

    add_index :inspection_template_categories,
              [:inspection_template_id, :name],
              unique: true,
              name: "idx_categories_on_template_and_name"

    # 2. Add nullable FK column to checklist_items
    add_reference :checklist_items,
                  :inspection_template_category,
                  foreign_key: { to_table: :inspection_template_categories }

    # 3. Backfill: for each distinct (template, category string), create a Category record
    ChecklistItem.select(:inspection_template_id, :category).distinct.each do |group|
      category = InspectionTemplateCategory.find_or_create_by!(
        inspection_template_id: group.inspection_template_id,
        name: group.category,
      )

      ChecklistItem.where(
        inspection_template_id: group.inspection_template_id,
        category: group.category,
      ).update_all(inspection_template_category_id: category.id)
    end

    # 4. Make the FK column NOT NULL now that backfill is complete
    change_column_null :checklist_items, :inspection_template_category_id, false

    # 5. Drop old unique index on [inspection_template_id, position]
    remove_index :checklist_items, name: "idx_checklist_items_on_template_and_position"

    # 6. Add new unique index on [inspection_template_category_id, position]
    add_index :checklist_items,
              [:inspection_template_category_id, :position],
              unique: true,
              name: "idx_items_on_category_and_position"

    # 7. Remove the old category string column
    remove_column :checklist_items, :category

    # 8. Rename table — FK references from inspection_items and inspection_photos
    #    automatically follow the new table name in PostgreSQL
    rename_table :checklist_items, :inspection_template_items
  end

  def down
    rename_table :inspection_template_items, :checklist_items

    add_column :checklist_items, :category, :string, default: "General", null: false

    remove_index :checklist_items, name: "idx_items_on_category_and_position"
    add_index :checklist_items,
              [:inspection_template_id, :position],
              unique: true,
              name: "idx_checklist_items_on_template_and_position"

    # Reverse backfill: restore category string from category name
    InspectionTemplateCategory.find_each do |cat|
      ChecklistItem.where(inspection_template_category_id: cat.id).update_all(category: cat.name)
    end

    remove_reference :checklist_items, :inspection_template_category

    remove_index :inspection_template_categories, name: "idx_categories_on_template_and_name"
    drop_table :inspection_template_categories
  end
end
