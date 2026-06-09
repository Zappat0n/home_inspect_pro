# frozen_string_literal: true

class InspectionPhotoProcessor::NullResponse
  class MissingPhotoError < StandardError; end

  def to_h
    raise(MissingPhotoError)
  end

  def needs_close?
    false
  end
end
