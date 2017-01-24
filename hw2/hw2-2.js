// find all with lowest score
db.grades.remove(db.grades.aggregate([{ $group: { "_id": "$student_id", "minScore": { $min: "$score" } } }]))
var c = db.grades.aggregate([{ $group: { "_id": "$student_id", "minScore": { $min: "$score" } } }]);
// remove them
