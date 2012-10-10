# app.rb
require 'sinatra'
require 'nokogiri'
require 'haml'
# require 'pry'

get '/' do
  haml :index
end
get '/results' do
  url = params['url']

  results = Nokogiri::XML(`java -jar ./tika-app-1.2.jar -x "#{url}"`)
  metadata = results.css('meta').map{|n| [n['name'], n['content']] }
  text  = results.css('body').text

  haml :results, locals: { metadata: metadata, text: text, url: url }
end