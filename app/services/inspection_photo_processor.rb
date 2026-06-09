# frozen_string_literal: true

class InspectionPhotoProcessor
  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
  end

  def call
    return NullResponse.new unless uploaded_file

    original_filename = File.basename(uploaded_file.original_filename, ".*")

    tempfile = Tempfile.new(["photo", ".webp"], binmode: true)
    ImageProcessing::Vips
      .source(uploaded_file.tempfile)
      .convert("webp")
      .saver(quality: 80, strip: true)
      .call(destination: tempfile.path)
    tempfile.rewind

    ProcessedResponse.new(
      io: tempfile,
      filename: "#{original_filename}.webp",
      content_type: "image/webp",
    )
  rescue Vips::Error
    OriginalResponse.new(uploaded_file)
  end

  private

  attr_reader :uploaded_file
end
