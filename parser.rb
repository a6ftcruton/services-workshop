require 'csv'
require 'json'
require 'redis-queue'

class Parser
  attr_reader :queue

  QUEUE_NAME = "fetcher_queue" # work queue
  PROCESSING_QUEUE_NAME = "fetcher_queue_processing" #processing queue

  def initialize
    @queue = Redis::Queue.new(QUEUE_NAME, PROCESSING_QUEUE_NAME, :redis => Redis.new)
  end

def parse(file_path)
    rows = CSV.read(file_path)
    headers = rows.shift
    attendees = rows.map do |row|
      headers.zip(row).to_h
    end
    attendees.first(20).each do |attendee|
      queue.push(attendee.to_json)
    end
  end
end

parse = Parser.new
parse.parse("./full_event_attendees.csv")
