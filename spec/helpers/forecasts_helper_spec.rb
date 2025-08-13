require 'rails_helper'

RSpec.describe ForecastsHelper, type: :helper do
  describe "#weather_code_to_description" do
    it "returns correct description for known code" do
      expect(helper.weather_code_to_description(0)).to eq("Clear Sky")
      expect(helper.weather_code_to_description(61)).to eq("Rain")
    end

    it "returns 'Unknown' for unrecognized codes" do
      expect(helper.weather_code_to_description(999)).to eq("Unknown")
    end
  end
end
