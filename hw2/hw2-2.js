// find all with lowest score
var c = db.grades.aggregate([{ $group: { "_id": "$student_id", "minScore": { $min: "$score" } } }]);
// remove them
db.grades.remove(db.grades.aggregate([{ $group: { "_id": "$student_id", "minScore": { $min: "$score" } } }]))

db.grades.aggregate({'$group':{'_id':'$student_id', 'average':{$avg:'$score'}}}, {'$sort':{'average':-1}}, {'$limit':1})
{"result" : [ {"_id" : 54, "average" : 96.19488173037341 } ], "ok" : 1 }
