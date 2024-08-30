import Foundation

struct TrainingSession: Identifiable, Codable {
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
}

struct Exercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var sets: [ExerciseSet]
    
    init(id: UUID = UUID(), name: String, sets: [ExerciseSet]) {
        self.id = id
        self.name = name
        self.sets = sets
    }
}

struct ExerciseSet: Identifiable, Codable {
    let id: UUID
    var weight: Double
    var reps: Int
    
    init(id: UUID = UUID(), weight: Double, reps: Int) {
        self.id = id
        self.weight = weight
        self.reps = reps
    }
}
