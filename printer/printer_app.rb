require 'sinatra'
require 'json'
require 'logger'

class PrinterApp < Sinatra::Base

  LOGGER = Logger.new(File.new("./attendees.log", 'a+'))

  get '/' do
    'Hello wordjkdfdk'
  end

  post '/attendees' do
    output = {:name => params[:name], 
              :congress_person => params[:congress_person],
              :zipcode => params[:zipcode]
             }
    LOGGER.info output.to_json
    params.to_s
  end
end
