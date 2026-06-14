# frozen_string_literal: true

class AddCaptionToInspectionPhotos < ActiveRecord::Migration[8.1]
  def change
    add_column(:inspection_photos, :caption, :string)
  end
end
