# frozen_string_literal: true

# Seed country-specific report templates
usa = Country.find_by!(code: "US")
canada = Country.find_by!(code: "CA")
spain = Country.find_by!(code: "ES")

ReportTemplate.find_or_create_by!(country: usa, locale: "en") do |rt|
  rt.header_text = "Home Inspection Report — Home Inspect Pro"
  rt.footer_text = "This report was generated electronically and is valid without a signature."
  rt.legal_disclaimer = "This inspection was performed in accordance with the standards of practice " \
                        "of InterNACHI/ASHI. The report reflects the visible conditions at the time of inspection."
end

ReportTemplate.find_or_create_by!(country: canada, locale: "en") do |rt|
  rt.header_text = "Home Inspection Report — Home Inspect Pro"
  rt.footer_text = "This report was generated electronically and is valid without a signature."
  rt.legal_disclaimer = "This inspection was performed in accordance with the standards of practice " \
                        "of CAHPI. The report reflects the visible conditions at the time of inspection."
end

ReportTemplate.find_or_create_by!(country: spain, locale: "es") do |rt|
  rt.header_text = "Informe de Inspección de Vivienda — Home Inspect Pro"
  rt.footer_text = "Este informe fue generado electrónicamente y es válido sin firma."
  rt.legal_disclaimer = "Esta inspección se realizó de acuerdo con los estándares de práctica de la ITE/IEE. " \
                        "El informe refleja las condiciones visibles en el momento de la inspección."
end

puts "Seeded #{ReportTemplate.count} report templates"
