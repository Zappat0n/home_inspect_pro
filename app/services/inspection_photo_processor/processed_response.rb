# frozen_string_literal: true

class InspectionPhotoProcessor::ProcessedResponse
  attr_reader :io, :filename, :content_type

  def initialize(io:, filename:, content_type:)
    @io = io
    @filename = filename
    @content_type = content_type
  end

  def to_h
    {
      io: io,
      filename: filename,
      content_type: content_type,
    }
  end

  def needs_close?
    true
  end
end
