# frozen_string_literal: true

class InspectionPhotosController < ApplicationController
  def create
    inspection = current_user.inspections.find(params[:inspection_id])
    inspection_item = inspection.inspection_items.find(params[:inspection_item_id])

    photo = build_photo(inspection, inspection_item)
    photo.photo.attach(**attachment_args.to_h)

    if photo.save
      render_create_success(photo, inspection_item, inspection)
    else
      render_create_error(photo, inspection_item, inspection)
    end
  rescue InspectionPhotoProcessor::NullResponse::MissingPhotoError
    render_create_error(photo, inspection_item, inspection)
  ensure
    attachment_args.io.close! if attachment_args.needs_close?
  end

  def destroy
    inspection = current_user.inspections.find(params[:inspection_id])
    photo = inspection.inspection_photos.find(params[:id])
    inspection_item = inspection.inspection_items.find_by!(checklist_item: photo.checklist_item)

    photo.destroy!

    render_destroy_success(photo, inspection_item, inspection)
  end

  private

  def build_photo(inspection, inspection_item)
    inspection.inspection_photos.build(
      checklist_item: inspection_item.checklist_item,
      position: inspection.next_photo_position,
    )
  end

  def attachment_args
    @_attachment_args ||= InspectionPhotoProcessor.new(params[:photo]).call
  end

  def render_create_success(photo, inspection_item, inspection)
    render(
      formats: :turbo_stream,
      locals: {
        photo: photo,
        inspection_item: inspection_item,
        inspection: inspection,
      },
    )
  end

  def render_create_error(photo, inspection_item, inspection)
    render(
      formats: :turbo_stream,
      status: :unprocessable_content,
      locals: {
        photo: photo,
        inspection_item: inspection_item,
        inspection: inspection,
      },
    )
  end

  def render_destroy_success(photo, inspection_item, inspection)
    render(
      formats: :turbo_stream,
      locals: {
        photo: photo,
        inspection_item: inspection_item,
        inspection: inspection,
      },
    )
  end
end
