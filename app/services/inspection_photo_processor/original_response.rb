# frozen_string_literal: true

class InspectionPhotoProcessor::OriginalResponse
  attr_reader :uploaded_file

  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
  end

  def to_h
    {
      io: uploaded_file,
      filename: uploaded_file.original_filename,
      content_type: uploaded_file.content_type,
    }
  end

  def needs_close?
    false
  end
end
