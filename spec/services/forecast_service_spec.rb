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

      allow(service).to receive(:fetch_weather).and_return(
        {
          temp: 21.1,
          high: 26.7,
          low: 15.6,
          extended_forecast: [{ date: Date.today, high: service.c_to_f(26.7), low: service.c_to_f(15.6), weathercode: 0 }]
        }
      )
    end

    it "fetches weather, converts temps to rounded Fahrenheit, and caches the result" do
      result = service.fetch_forecast

      expect(result).to be_a(ForecastService::WeatherData)
      expect(result.temperature).to eq(70)
      expect(result.high).to eq(80)
      expect(result.low).to eq(60)
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

  context 'extended forecast' do
    it 'includes extended forecast with correct Fahrenheit values and weather codes' do
      service = ForecastService.new('65613')

      allow(service).to receive(:geocode_zipcode).and_return('65613')
      allow(service).to receive(:lat_lon).and_return([37.614, -93.410])
      allow(service).to receive(:fetch_weather).and_return(
        {
          temp: 20.0,
          high: 25.0,
          low: 15.0,
          extended_forecast: [
            { date: Date.today, high: service.c_to_f(25), low: service.c_to_f(15), weathercode: 0 }
          ]
        }
      )

      result = service.fetch_forecast

      expect(result.extended_forecast).to eq([
        {
          date: Date.today,
          high: 77,
          low: 59,
          weathercode: 0
        }
      ])
    end
  end
end
