require 'rails_helper'

RSpec.describe "forecasts/index.html.erb", type: :view do
  let(:zipcode) { "65613" }
  let(:forecast_data) do
    ForecastService::WeatherData.new(
      70, 80, 60, false,
      [
        { date: Date.today, high: 80, low: 60, weathercode: 0 }
      ]
    )
  end

  before do
    assign(:zipcode, zipcode)
  end

  context "when forecast is present" do
    before do
      assign(:forecast, forecast_data)
      allow(view).to receive(:weather_code_to_description).and_return("Clear Sky")
      render
    end

    it "renders the current temperature, high, and low" do
      expect(rendered).to include("Current Temperature: 70°F")
      expect(rendered).to include("High: 80°F")
      expect(rendered).to include("Low: 60°F")
    end

    it "renders the extended forecast table" do
      expect(rendered).to include("<table")
      expect(rendered).to include("7-Day Forecast")
      expect(rendered).to include("Clear Sky")
    end
  end

  context "when forecast is nil and alert is present" do
    before do
      assign(:forecast, nil)
      flash.now[:alert] = "Could not retrieve forecast"
      render
    end

    it "displays the alert message" do
      expect(rendered).to include("Could not retrieve forecast")
    end
  end

  context "form behavior" do
    before do
      assign(:forecast, nil)
      render
    end

    it "shows the address input field with the placeholder" do
      expect(rendered).to include('placeholder="e.g. 102 E Broadway St, Bolivar, MO 65613"')
      expect(rendered).to include("Enter an Address or Zip/Postal Code:")
    end
  end
end
