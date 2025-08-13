# README

## ruby-weather-app

A simple Ruby on Rails application to fetch and display weather forecasts based on a user-specified address or zipcode.

### Features
* Accepts a full address or simple zip/postal code inputted by the user
* Geocodes the input to latitude and longitude using the Geocoder gem (OpenStreetMap Nominatim)
* Retrieves current weather and 7-day forecast data from the Open-Meteo API
* Caches forecast data based on the address's zipcode for 30 minutes to improve performance
* Displays current temperature, highs and lows, and weather conditions for the next 7 days

### Tech Stack
* Ruby on Rails
* RSpec for testing
* Faraday for HTTP requests
* Geocoder gem for geocoding addresses
* Open-Meteo API for weather data

## Setup
### Prerequisites
* Ruby 3.3.5
* Rails 7
* Bundler

### Installation
Clone the repo:
```
git clone https://github.com/nathan-schulz/ruby-weather-app.git
cd ruby-weather-app
```
Install dependencies:
```
bundle install
```
Setup the database:
```
rails db:create db:migrate
```
Run the Rails server:
```
rails server
Visit http://localhost:3000/ in your browser.
```

### Running Tests
Run the RSpec test suite with:
```
bundle exec rspec
```

### Usage
* Enter an address or zipcode into the input field on the forecast page.
* Submit the form to see current and 7-day weather forecasts.


### Caching
Forecast results are cached by zipcode for 30 minutes to reduce API calls and speed up responses.

### Notes
* This app uses the OpenStreetMap Nominatim service via the Geocoder gem for free geocoding
* The Open-Meteo API is used for weather data without requiring an API key
