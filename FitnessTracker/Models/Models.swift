import Foundation
import GRDB

struct TrainingSession: Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: UUID
    var date: Date
    var bodyPart: String
    var exercises: [Exercise]
    var duration: Int
    var startTime: Date?

    init(id: UUID = UUID(), date: Date, bodyPart: String, exercises: [Exercise] = [], duration: Int = 0, startTime: Date? = nil) {
        self.id = id
        self.date = date
        self.bodyPart = bodyPart
        self.exercises = exercises
        self.duration = duration
        self.startTime = startTime
    }
    
    static let exercises = hasMany(Exercise.self)
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Implementation not needed as we're using UUID
    }
}

struct Exercise: Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: UUID
    var name: String
    var sets: [ExerciseSet]
    var sessionId: UUID

    init(id: UUID = UUID(), name: String, sets: [ExerciseSet] = [], sessionId: UUID) {
        self.id = id
        self.name = name
        self.sets = sets
        self.sessionId = sessionId
    }
    
    static let session = belongsTo(TrainingSession.self)
    static let sets = hasMany(ExerciseSet.self)
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Implementation not needed as we're using UUID
    }
}

struct ExerciseSet: Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: UUID
    var weight: Double
    var reps: Int
    var exerciseId: UUID

    init(id: UUID = UUID(), weight: Double, reps: Int, exerciseId: UUID) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.exerciseId = exerciseId
    }
    
    static let exercise = belongsTo(Exercise.self)
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Implementation not needed as we're using UUID
    }
}
