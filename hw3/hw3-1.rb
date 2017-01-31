require 'mongo'
require 'pry'

client = Mongo::Client.new(['127.0.0.1:27017'], database: 'school')
collection = client[:students]

cursor = collection.find({ 'scores.type': 'homework' })

def rmv_low_score(scores)
  lowest = []
  lowest << scores.select { |s| s[:type] == 'homework'}.min_by{ |x| x[:score] }
  (scores | lowest) - (scores & lowest)
end

def upd_without_low_score(collection, id, lowest_scores)
  collection.update_one({ "_id": "#{id}" }, { "$set": { "scores": "#{lowest_scores}" } })
end

for doc in cursor
  id = doc[:_id]
  scores = doc[:scores]
  lowest_scores_hw_removed = rmv_low_score(scores)
  # p "\"_id\": #{id}, \"scores\": #{lowest_scores}"
  # doc[:scores] = lowest_scores_hw_removed
  upd_without_low_score(collection, id, lowest_scores_hw_removed)
end
