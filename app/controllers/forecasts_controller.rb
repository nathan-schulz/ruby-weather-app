# ForecastsController
# Responsible for:
# - Accepting a zipcode from the user's specified address
# - Passing the zipcode to ForecastService to retrieve weather data
# - Displaying the results in the view, or showing an alert if retrieval fails
class ForecastsController < ApplicationController
  # Displays the weather forecast for the given zipcode
  #
  # Zipcode comes from params[:zipcode]
  # Uses ForecastService to fetch the forecast and stores it in @forecast
  # for the view to display.
  #
  # @return [void]
  def index
    @zipcode = params[:zipcode]

    if @zipcode.present?
      service = ForecastService.new(@zipcode)
      @forecast = service.fetch_forecast

      flash.now[:alert] = "Could not retrieve forecast for #{@zipcode}." if @forecast.nil?
    else
      @forecast = nil
    end
  end
end
