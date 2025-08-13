require 'rails_helper'

RSpec.describe "Forecasts", type: :request do
  describe "GET /forecasts" do
    let(:zipcode) { "65613" }
    let(:forecast_data) do
      extended = [{ date: Date.today, high: 80, low: 65, description: "Clear Sky" }]
      ForecastService::WeatherData.new(68, 80, 65, false, extended)
    end

    context "when forecast is successfully retrieved" do
      before do
        allow_any_instance_of(ForecastService)
          .to receive(:fetch_forecast)
          .and_return(forecast_data)
      end

      it "assigns @forecast and renders the index template" do
        get forecasts_path, params: { zipcode: zipcode }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Forecast for #{zipcode}")
        expect(response.body).to include("Current Temperature: #{forecast_data.temperature}°F")
      end
    end

    context "when forecast retrieval fails" do
      before do
        allow_any_instance_of(ForecastService)
          .to receive(:fetch_forecast)
          .and_return(nil)
      end

      it "sets an alert message and renders the index template" do
        get forecasts_path, params: { zipcode: "99999" }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Could not retrieve forecast for 99999.")
      end
    end
  end
end
