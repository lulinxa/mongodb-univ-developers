require 'mongo'

client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'm101')
collection = client[:funnynumbers]
magic = 0
collection.find.each do |document|
  if((document[:value] % 3) == 0)
    magic = magic + document[:value]
  end
end
puts magic
