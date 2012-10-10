# app.rb
require 'bundler/setup'
Bundler.require(:default)
require 'open3'

get '/' do
  haml :index
end
get '/results' do
  begin
    raise if (url = params['url']).empty?
    results = tika(url)
    @flash = { error: ["Errors occured! See below"] } if results[:errors]
    haml :results, locals: results
  rescue
    @flash = { error: ["Something went wrong! Try a different URL"] }
    halt 500, haml(:index)
  end
end

def get_tika_results(url)
  xml_out, errors, _ = Open3.capture3("java -jar ./tika-app-1.2.jar -x '#{url}'")
  errors = nil if errors.empty?
  [xml_out, errors]
end

def tika(url)
  results, errors = get_tika_results(url)
  results = Nokogiri::XML(results)

  metadata = results.css('meta').map{|n| [n['name'], n['content']] }
  text  = results.css('body').text

  { metadata: metadata, text: text, errors: errors, url: url }
end