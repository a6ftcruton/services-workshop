require 'redis-queue'
require 'sunlight'
require 'faraday'

class Fetcher
  QUEUE_NAME = "fetcher_queue" # work queue
  PROCESSING_QUEUE_NAME = "fetcher_queue_processing" #processing queue
  SUNLIGHT_KEY = 'f36d4c02185c42be86bcb6ab7c9c2091'

  def initialize
    @redis = Redis.new
    @queue = Redis::Queue.new(QUEUE_NAME, PROCESSING_QUEUE_NAME, :redis => @redis)
    Sunlight::Base.api_key = SUNLIGHT_KEY
  end

  def run
    @queue.process do |message|
      puts "Fetcher processing..."
      data = JSON.parse(message)
      name = data["first_Name"] + " " + data["last_Name"] 
      zipcode = data["Zipcode"]
      congress_person = fetch_congress_person(zipcode)
      send_data_to_printer(name, zipcode, congress_person)
      true
    end
  end

  def send_data_to_printer(name, zipcode, congress_person)
    printer_client.post('/attendees', {name: name, 
                                       zipcode: zipcode, 
                                       congress_person: congress_person}) 
  end

  def printer_client
    conn = Faraday.new(:url => 'http://localhost:9292') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def fetch_congress_person(zipcode)
    members_of_congress = Sunlight::Legislator.all_in_zipcode(zipcode.to_i)
    if members_of_congress.any? 
      members_of_congress.first.firstname + " " + members_of_congress.first.lastname
    else
      "Unknown"
    end
  end
end

Fetcher.new.run
