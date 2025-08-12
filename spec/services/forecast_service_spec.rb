require 'rails_helper'

RSpec.describe ForecastService do
  let(:address) { "65613" } # Bolivar, MO, USA
  subject(:service) { described_class.new(address) }

  before(:each) do
    Rails.cache.clear

    allow(Geocoder).to receive(:search).and_return([
      double(
        postal_code: "65613",
        latitude: 37.6145,
        longitude: -93.4105
      )
    ])
  end

  context "when cached data exists" do
    before do
      allow(service).to receive(:fetch_weather)
    end

    it "returns cached weather data" do
      cached_data = ForecastService::WeatherData.new(72, 91, 68, true)
      Rails.cache.write("forecast:65613", cached_data, expires_in: 30.minutes)

      result = service.fetch_forecast

      expect(result).to eq(cached_data)
      expect(result.cached).to be true
    end
  end

  context "when no cached data exists" do
    before do
      Rails.cache.clear

      fake_response = instance_double(Faraday::Response, success?: true, body: {
        "current_weather" => { "temperature" => 21.1 },  # Celsius 21.1 ~ 70F
        "daily" => {
          "temperature_2m_max" => [26.7],  # Celsius 26.7 ~ 80F
          "temperature_2m_min" => [15.6]   # Celsius 15.6 ~ 60F
        }
      }.to_json)

      allow(Faraday).to receive(:get).and_return(fake_response)
    end

    it "fetches weather, converts temps to Fahrenheit, and caches the result" do
      result = service.fetch_forecast

      expect(result).to be_a(ForecastService::WeatherData)
      expect(result.temperature).to be_within(0.1).of(70.0)
      expect(result.high).to be_within(0.1).of(80.0)
      expect(result.low).to be_within(0.1).of(60.0)
      expect(result.cached).to be false

      cached = Rails.cache.read("forecast:65613")
      expect(cached).to eq(result)
    end
  end

  context "when geocoding fails" do
    before do
      allow(Geocoder).to receive(:search).with(address).and_return([])
    end

    it "returns nil" do
      expect(service.fetch_forecast).to be_nil
    end
  end

  context "when API call fails" do
    before do
      Rails.cache.clear

      allow(Faraday).to receive(:get).and_return(
        instance_double(Faraday::Response, success?: false)
      )
    end

    it "returns nil" do
      expect(service.fetch_forecast).to be_nil
    end
  end
end
