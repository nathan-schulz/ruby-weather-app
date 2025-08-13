# ForecastsHelper
# Responsible for:
# - Converting the Open-Meteo weather codes into human-readable weather descriptions
module ForecastsHelper
  # Converts a numeric weather code from Open-Meteo into a descriptive string
  #
  # @param code [Integer] The weather code from the Open-Meteo API
  # @return [String] A human-readable description of the weather condition
  def weather_code_to_description(code)
    case code
    when 0 then "Clear Sky"
    when 1, 2, 3 then "Partly Cloudy"
    when 45, 48 then "Foggy"
    when 51, 53, 55 then "Light Rain"
    when 61, 63, 65 then "Rain"
    when 71, 73, 75 then "Snow"
    when 80, 81, 82 then "Heavy Rain"
    when 95 then "Thunderstorm"
    else "Unknown"
    end
  end
end
