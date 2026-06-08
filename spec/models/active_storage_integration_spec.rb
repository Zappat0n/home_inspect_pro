require "rails_helper"

RSpec.describe "Active Storage integration", type: :model do
  describe "file upload and management" do
    it "uploads and attaches a file to a record" do
      inspection = create(:inspection)

      blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(Rails.root.join("spec/fixtures/files/test.txt")),
        filename: "test.txt",
        content_type: "text/plain",
      )

      attachment = ActiveStorage::Attachment.create!(
        name: "photos",
        record_type: "Inspection",
        record_id: inspection.id,
        blob: blob,
      )

      expect(attachment).to be_persisted
      expect(blob).to be_persisted
      expect(blob.byte_size).to be > 0
      expect(blob.filename.to_s).to eq("test.txt")
      expect(blob.content_type).to eq("text/plain")
    end

    it "retrieves file content and purges the blob" do
      blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(Rails.root.join("spec/fixtures/files/test.txt")),
        filename: "test.txt",
        content_type: "text/plain",
      )

      content = blob.download

      expect(content).to eq("Hello, Active Storage!")

      blob.purge

      expect(ActiveStorage::Blob.exists?(blob.id)).to be false
    end
  end
end
