class CreateCountries < ActiveRecord::Migration[8.2]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :code
      t.string :locale
      t.boolean :available
      t.boolean :is_default

      t.timestamps
    end
  end
end
