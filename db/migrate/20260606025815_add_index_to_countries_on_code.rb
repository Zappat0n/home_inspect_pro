class AddIndexToCountriesOnCode < ActiveRecord::Migration[8.2]
  def change
    add_index :countries, :code, unique: true
  end
end
