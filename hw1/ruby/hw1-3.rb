require 'sinatra'
require 'mongo'

get '/hello/:id' do # /hello/:name
  # @name = params['name']
  @n = params['id']
  client = Mongo::Client.new('mongodb://127.0.0.1:27017/m101')
  collection = client[:funnynumbers]
  v = collection.find.skip(@n.to_i).limit(1).sort(value: 1)
  v.each do |x|
    @name = x[:value]
  end
  haml :index
end
