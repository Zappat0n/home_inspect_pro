# frozen_string_literal: true

require "rails_helper"

RSpec.describe PdfReportService do
  describe "#call" do
    it "generates a PDF and attaches it to the inspection" do
      country = create(:country, locale: "en")
      create(:report_template, country: country, locale: "en")
      template = create(:inspection_template, country: country, published: true)
      roof_category = create(:inspection_template_category, inspection_template: template, name: "Roof")
      electrical_category = create(:inspection_template_category, inspection_template: template, name: "Electrical")
      inspection = create(:inspection, inspection_template: template)

      # Critical defect with photos
      roof_item = create(
        :checklist_item,
        inspection_template: template,
        inspection_template_category: roof_category,
        name: "Shingles",
        severity: :critical,
        allows_photo: true,
        position: 1,
      )
      create(
        :inspection_item,
        inspection: inspection,
        checklist_item: roof_item,
        status: :defect,
        comment: "Missing shingles on east side",
      )

      # Major defect
      electrical_item = create(
        :checklist_item,
        inspection_template: template,
        inspection_template_category: electrical_category,
        name: "Outlet",
        severity: :major,
        position: 2,
      )
      create(
        :inspection_item,
        inspection: inspection,
        checklist_item: electrical_item,
        status: :defect,
        comment: "Faulty wiring",
      )

      # OK item (no defect)
      ok_item = create(
        :checklist_item,
        inspection_template: template,
        inspection_template_category: electrical_category,
        name: "Breaker",
        position: 3,
      )
      create(:inspection_item, inspection: inspection, checklist_item: ok_item, status: :ok)

      # Attach two photos to the roof item (11.9.2 photo grid)
      photo1 = build(:inspection_photo, inspection: inspection, checklist_item: roof_item, position: 1)
      photo1.photo.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
        filename: "shingles_1.jpg",
        content_type: "image/jpeg",
      )
      photo1.save!

      photo2 = build(:inspection_photo, inspection: inspection, checklist_item: roof_item, position: 2)
      photo2.photo.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
        filename: "shingles_2.jpg",
        content_type: "image/jpeg",
      )
      photo2.save!

      ActiveStorage::Current.url_options = { host: "http://localhost:3000" }
      grover_double = instance_double(Grover, to_pdf: "fake pdf content")
      rendered_html = nil
      allow(Grover).to receive(:new) do |html|
        rendered_html = html
        grover_double
      end

      described_class.new(inspection).call

      # Basic attachment assertions
      expect(inspection.pdf).to be_attached
      expect(inspection.pdf_url).to be_present
      expect(rendered_html).to include("Roof")
      expect(rendered_html).to include("Electrical")
      expect(rendered_html).to include("Shingles")
      expect(rendered_html).to include("Breaker")

      # 11.9.1 — Defects summary grouping & stats
      expect(rendered_html).to include("2 defects total, 1 critical, 1 major")
      expect(rendered_html).to include("severity-badge--critical")
      expect(rendered_html).to include("severity-badge--major")
      critical_idx = rendered_html.index("severity-badge--critical")
      major_idx = rendered_html.index("severity-badge--major")
      expect(critical_idx).to be < major_idx

      defects_section = rendered_html.split("Defects Summary").last
      expect(defects_section).to include("Missing shingles on east side")
      expect(defects_section).to include("Faulty wiring")

      # 11.9.2 — Larger thumbnails + 2-column photo grid
      expect(rendered_html).to include("item-photos--multiple")
      expect(rendered_html).to include('class="item-photo"')

      # 11.9.3 — Table of contents
      expect(rendered_html).to include(I18n.t("reports.show.table_of_contents"))
      expect(rendered_html).to include('href="#category-roof"')
      expect(rendered_html).to include('class="toc-dot toc-dot--defects"')

      # 11.9.4 — QR code footer
      expect(rendered_html).to include("<svg")
      expect(rendered_html).to include(I18n.t("reports.show.report_id"))
      expect(rendered_html).to include(inspection.id.to_s)
      expect(rendered_html).to include(I18n.t("reports.show.generated_at"))
    end

    it "generates a PDF with Spanish locale" do
      country = create(:country, locale: "es")
      create(:report_template, country: country, locale: "es")
      template = create(:inspection_template, country: country, published: true)
      inspection = create(:inspection, inspection_template: template)

      ActiveStorage::Current.url_options = { host: "http://localhost:3000" }
      grover_double = instance_double(Grover, to_pdf: "fake pdf content")
      allow(Grover).to receive(:new).and_return(grover_double)

      described_class.new(inspection).call

      expect(inspection.pdf).to be_attached
    end

    it "uses default_url_options host and port for base_url" do
      previous_routes_opts = Rails.application.routes.default_url_options.dup
      previous_mailer_opts = Rails.application.config.action_mailer.default_url_options.dup

      Rails.application.routes.default_url_options = { host: "example.com", port: 3000 }

      country = create(:country, locale: "en")
      create(:report_template, country: country, locale: "en")
      template = create(:inspection_template, country: country, published: true)
      inspection = create(:inspection, inspection_template: template)

      ActiveStorage::Current.url_options = { host: "http://localhost:3000" }
      grover_double = instance_double(Grover, to_pdf: "fake pdf content")
      rendered_html = nil
      allow(Grover).to receive(:new) do |html|
        rendered_html = html
        grover_double
      end

      described_class.new(inspection).call

      expect(inspection.pdf_url).to include("example.com:3000")
    ensure
      Rails.application.routes.default_url_options = previous_routes_opts
      Rails.application.config.action_mailer.default_url_options = previous_mailer_opts
    end

    it "falls back to action_mailer default_url_options when routes options are blank" do
      previous_routes_opts = Rails.application.routes.default_url_options.dup
      previous_mailer_opts = Rails.application.config.action_mailer.default_url_options.dup

      Rails.application.routes.default_url_options = {}
      Rails.application.config.action_mailer.default_url_options = { host: "mailer.example.com" }

      country = create(:country, locale: "en")
      create(:report_template, country: country, locale: "en")
      template = create(:inspection_template, country: country, published: true)
      inspection = create(:inspection, inspection_template: template)

      ActiveStorage::Current.url_options = { host: "http://localhost:3000" }
      grover_double = instance_double(Grover, to_pdf: "fake pdf content")
      allow(Grover).to receive(:new).and_return(grover_double)

      described_class.new(inspection).call

      expect(inspection.pdf_url).to include("mailer.example.com")
    ensure
      Rails.application.routes.default_url_options = previous_routes_opts
      Rails.application.config.action_mailer.default_url_options = previous_mailer_opts
    end

    it "uses protocol from default_url_options for base_url" do
      previous_routes_opts = Rails.application.routes.default_url_options.dup
      previous_mailer_opts = Rails.application.config.action_mailer.default_url_options.dup

      Rails.application.routes.default_url_options = { host: "secure.example.com", protocol: "https" }

      country = create(:country, locale: "en")
      create(:report_template, country: country, locale: "en")
      template = create(:inspection_template, country: country, published: true)
      inspection = create(:inspection, inspection_template: template)

      ActiveStorage::Current.url_options = { host: "http://localhost:3000" }
      grover_double = instance_double(Grover, to_pdf: "fake pdf content")
      allow(Grover).to receive(:new).and_return(grover_double)

      described_class.new(inspection).call

      expect(inspection.pdf_url).to include("https://secure.example.com")
    ensure
      Rails.application.routes.default_url_options = previous_routes_opts
      Rails.application.config.action_mailer.default_url_options = previous_mailer_opts
    end

    it "defaults to http://localhost when all options are blank" do
      previous_routes_opts = Rails.application.routes.default_url_options.dup
      previous_mailer_opts = Rails.application.config.action_mailer.default_url_options.dup

      Rails.application.routes.default_url_options = {}
      Rails.application.config.action_mailer.default_url_options = {}

      country = create(:country, locale: "en")
      create(:report_template, country: country, locale: "en")
      template = create(:inspection_template, country: country, published: true)
      inspection = create(:inspection, inspection_template: template)

      ActiveStorage::Current.url_options = { host: "http://localhost:3000" }
      grover_double = instance_double(Grover, to_pdf: "fake pdf content")
      allow(Grover).to receive(:new).and_return(grover_double)

      described_class.new(inspection).call

      expect(inspection.pdf_url).to include("http://localhost")
    ensure
      Rails.application.routes.default_url_options = previous_routes_opts
      Rails.application.config.action_mailer.default_url_options = previous_mailer_opts
    end

    it "generates a PDF with a custom template" do
      country = create(:country, locale: "en")
      create(:report_template, country: country, locale: "en")
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country, published: true)
      roof_category = create(:inspection_template_category, inspection_template: template, name: "Roof")
      inspection = create(:inspection, inspection_template: template)
      item = create(
        :checklist_item,
        inspection_template: template,
        inspection_template_category: roof_category,
        name: "Shingles",
        position: 1,
      )
      create(:inspection_item, inspection: inspection, checklist_item: item, status: :ok)

      ActiveStorage::Current.url_options = { host: "http://localhost:3000" }
      grover_double = instance_double(Grover, to_pdf: "fake pdf content")
      rendered_html = nil
      allow(Grover).to receive(:new) do |html|
        rendered_html = html
        grover_double
      end

      described_class.new(inspection).call

      expect(inspection.pdf).to be_attached
      expect(inspection.pdf_url).to be_present
      expect(rendered_html).to include("Shingles")
    end
  end
end
