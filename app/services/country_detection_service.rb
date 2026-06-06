# frozen_string_literal: true

class CountryDetectionService
  DEFAULT_COUNTRY_CODE = "US"
  DEFAULT_COUNTRY_NAME = "United States"
  DEFAULT_LOCALE = "en"

  def initialize(ip)
    @ip = ip
  end

  def call
    Country.find_or_create_by!(code: country_code) do |country|
      country.name = country_name
      country.locale = DEFAULT_LOCALE
      country.available = false
    end
  end

  private

  attr_reader :ip

  def result
    @_result ||= Geocoder.search(ip).first
  end

  def country_code
    return DEFAULT_COUNTRY_CODE unless result

    result.country_code
  end

  def country_name
    return DEFAULT_COUNTRY_NAME unless result

    result.country_name
  end
end
