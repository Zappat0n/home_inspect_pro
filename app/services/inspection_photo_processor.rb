# frozen_string_literal: true

class InspectionPhotoProcessor
  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
  end

  def call
    return uploaded_file unless uploaded_file.respond_to?(:tempfile)

    tempfile = Tempfile.new(["photo", ".webp"], binmode: true)
    ImageProcessing::Vips
      .source(uploaded_file.tempfile)
      .convert("webp")
      .saver(quality: 80, strip: true)
      .call(destination: tempfile.path)
    tempfile.rewind

    {
      io: tempfile,
      filename: "#{File.basename(@uploaded_file.original_filename, '.*')}.webp",
      content_type: "image/webp",
      tempfile: tempfile,
    }
  rescue Vips::Error
    uploaded_file
  end

  private

  attr_reader :uploaded_file
end
