require 'mongo'

client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'students')
collection = client[:grades]

cursor = collection.find(type: 'homework').sort(student_id: 1, score: 1)

prev_id = nil
student_id = nil

for doc in cursor
  student_id = doc[:student_id]
  if student_id != prev_id
    prev_id = student_id
    p "Remove #{doc[:_id]}"
    doc.delete
  end
end
