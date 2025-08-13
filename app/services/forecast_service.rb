require 'faraday'
require 'json'

# ForecastService
# Responsible for:
# - Geocoding a specified address to get latitude, longitude, and zipcode
# - Fetching current weather, high, and low temperatures from a weather API
# - Caching the results for 30 minutes
class ForecastService
  CACHE_RESET_TIME = 30.minutes

  # Struct to hold weather data, boolean val for if it was returned from the cache, and data for the extended forecast
  WeatherData = Struct.new(:temperature, :high, :low, :cached, :extended_forecast)

  # Initialize the service with the specified address string
  #
  # @param address [String] The specified address
  def initialize(address)
    @address = address
  end

  # Fetches the forecast data
  #
  # Returns cached data if available, otherwise fetches fresh data
  #
  # @return [WeatherData, nil] Returns weather data or nil if the geocoding or API call fails
  def fetch_forecast
    zipcode = geocode_zipcode
    return nil unless zipcode

    # Attempt to read the already cached weather data by zipcode
    cached_data = Rails.cache.read(cache_key(zipcode))
    if cached_data
      cached_data.cached = true
      return cached_data
    end

    # If no data is found in the cache, fetch fresh weather data using lat/lon coordinates
    weather = fetch_weather(lat_lon)
    return nil unless weather

    # Create a WeatherData struct with the retrieved weather data
    data = WeatherData.new(
      c_to_f(weather[:temp]),     # current temperature
      c_to_f(weather[:high]),     # today's high temperature
      c_to_f(weather[:low]),      # today's low temperature
      false,                      # cached is false, since we fetched fresh data
      weather[:extended_forecast] # data for the extended forecast
    )

    # Cache the new weather data with the set CACHE_RESET_TIME
    Rails.cache.write(cache_key(zipcode), data, expires_in: CACHE_RESET_TIME)

    data
  end

  # Converts the temperature from Celsius to Fahrenheit, rounded to nearest integer
  #
  # @param celsius [Float, nil] Temperature in Celsius
  # @return [Integer, nil] Temperature converted to Fahrenheit and rounded, or nil if input is nil
  def c_to_f(celsius)
    return nil if celsius.nil?
    ((celsius * 9.0 / 5.0) + 32).round
  end

  private

  # Geocode the specified address to find the latitude, longitude, and zipcode
  #
  # Uses the Geocoder gem, which uses OpenStreetMap’s Nominatim service
  #
  # @return [String, nil] The zipcode string if it's found, otherwise nil
  def geocode_zipcode
    results = Geocoder.search(@address)
    return nil if results.blank?

    location = results.first

    # Extract zipcode (postal code) from geocoding result
    zipcode = location.postal_code

    # Store latitude and longitude for the weather API lookup
    @lat_lon = [location.latitude, location.longitude]

    zipcode
  end

  # Return stored latitude and longitude array
  #
  # @return [Array<Float>] [latitude, longitude]
  def lat_lon
    @lat_lon
  end

  # Fetches current weather data from the external Open-Meteo API
  #
  # Uses the latitude and longitude to request current weather,
  # and daily high/low temperatures
  #
  # @param lat_lon [Array<Float>] Latitude and longitude coordinates
  #
  # @return [Hash, nil] Returns hash with :temp, :high, :low keys, or nil on failure
  def fetch_weather(lat_lon)
    return nil unless lat_lon && lat_lon.size == 2

    lat, lon = lat_lon

    url = "https://api.open-meteo.com/v1/forecast" # Static Open-Meteo API URL
    params = {
      latitude: lat,
      longitude: lon,
      current_weather: true,
      daily: 'temperature_2m_max,temperature_2m_min,weathercode',
      timezone: 'auto'
    }

    # Make a GET request using the Faraday gem
    response = Faraday.get(url, params)

    # Return nil if the response is unsuccessful
    return nil unless response.success?

    # Parse the JSON response body
    json = JSON.parse(response.body)

    # Build an extended forecast array of hashes (date, high, low, weathercode)
    extended_forecast = json['daily']['time'].zip(
      json['daily']['temperature_2m_max'],
      json['daily']['temperature_2m_min'],
      json['daily']['weathercode']
    ).map do |date, max, min, code|
      {
        date: date,
        high: c_to_f(max),
        low: c_to_f(min),
        weathercode: code
      }
    end

    # Extract and return the current temperature, daily max (high), daily min (low) temperatures, and extended forecast
    {
      temp: json.dig("current_weather", "temperature"),
      high: json.dig("daily", "temperature_2m_max")&.first,
      low: json.dig("daily", "temperature_2m_min")&.first,
      extended_forecast: extended_forecast
    }
  rescue StandardError => e
    # Log errors for debugging and then fail gracefully by returning nil
    Rails.logger.error("ForecastService fetch_weather error: #{e.message}")
    nil
  end

  # Build the cache key string for the specified zipcode
  #
  # @param zipcode [String] The zipcode used for the caching key
  #
  # @return [String] Cache key string
  def cache_key(zipcode)
    "forecast:#{zipcode}"
  end
end
