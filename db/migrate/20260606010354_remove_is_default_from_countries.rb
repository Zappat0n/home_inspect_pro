class RemoveIsDefaultFromCountries < ActiveRecord::Migration[8.2]
  def change
    remove_column(:countries, :is_default, :boolean)
  end
end
