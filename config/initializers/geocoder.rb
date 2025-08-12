Geocoder.configure(
  timeout: 5,
  lookup: :nominatim,
  units: :mi,
  http_headers: { "User-Agent" => "RubyWeatherApp/1.0" }
)
