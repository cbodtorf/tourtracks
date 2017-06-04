require 'songkickr'

class HomeController < ApplicationController

  def index

  end

  def search
    @url_base = "http://api.songkick.com/api/3.0"
    @api_key = ENV['SONGKICK_API_KEY']

    zipConversion = ZipCodes.identify(params[:q])
    Rails.logger.debug("zip: #{zipConversion.inspect}")

    location_q = "#{zipConversion[:city]},#{zipConversion[:state_code]}"
    locations = HTTParty.get("#{@url_base}/search/locations.json?query=#{location_q}&apikey=#{@api_key}")
    # Rails.logger.debug("locations: #{locations.parsed_response["resultsPage"]["results"]["location"].inspect}")

    event_q = locations.parsed_response["resultsPage"]["results"]["location"].first["metroArea"]["id"]
    @events = HTTParty.get("#{@url_base}/events.json?apikey=#{@api_key}&location=sk:#{event_q}")
    # Rails.logger.debug("events: #{@events.parsed_response["resultsPage"]["results"]["event"].inspect}")
    @events = @events.parsed_response["resultsPage"]["results"]["event"]

    @artists = @events.map do |event|
      event["performance"][0]["artist"]["displayName"]
    end.uniq

    render('index')
  end
end
