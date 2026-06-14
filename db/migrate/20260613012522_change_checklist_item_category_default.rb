class ChangeChecklistItemCategoryDefault < ActiveRecord::Migration[8.1]
  def up
    execute(<<~SQL.squish)
      UPDATE checklist_items
      SET category = 'General'
      WHERE category IS NULL OR category = ''
    SQL

    execute(<<~SQL.squish)
      ALTER TABLE checklist_items
        ALTER COLUMN category SET NOT NULL,
        ALTER COLUMN category SET DEFAULT 'General'
    SQL
  end

  def down
    execute(<<~SQL.squish)
      ALTER TABLE checklist_items
        ALTER COLUMN category DROP NOT NULL,
        ALTER COLUMN category DROP DEFAULT
    SQL
  end
end
