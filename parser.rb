require 'csv'

class Parser
  def parse(file_path)
    rows = CSV.read(file_path)
    headers = rows.shift
    attendees = rows.map do |row|
      headers.zip(row).to_h
    end
    p attendees.first(10)
  end
end

parse = Parser.new
parse.parse("./full_event_attendees.csv")
