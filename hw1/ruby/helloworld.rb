require 'sinatra'

get '/hello/:name' do # /hello/:name
  @name = params['name']
  haml :index
end
