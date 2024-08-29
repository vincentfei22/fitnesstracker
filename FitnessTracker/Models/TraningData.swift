import Foundation
import GRDB

class TrainingData: ObservableObject {
    private let dbQueue: DatabaseQueue
    @Published var sessions: [TrainingSession] = []

    init() {
        do {
            let fileManager = FileManager.default
            let databaseURL = try fileManager
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("FitnessTracker.sqlite")

            dbQueue = try DatabaseQueue(path: databaseURL.path)

            try dbQueue.write { db in
                try db.create(table: "trainingSession", ifNotExists: true) { t in
                    t.column("id", .text).primaryKey()
                    t.column("date", .datetime)
                    t.column("bodyPart", .text)
                    t.column("duration", .integer)
                    t.column("startTime", .datetime)
                }

                try db.create(table: "exercise", ifNotExists: true) { t in
                    t.column("id", .text).primaryKey()
                    t.column("sessionId", .text).references("trainingSession", onDelete: .cascade)
                    t.column("name", .text)
                }

                try db.create(table: "exerciseSet", ifNotExists: true) { t in
                    t.column("id", .text).primaryKey()
                    t.column("exerciseId", .text).references("exercise", onDelete: .cascade)
                    t.column("weight", .double)
                    t.column("reps", .integer)
                }
            }

            loadSessions()
        } catch {
            fatalError("Database initialization failed: \(error.localizedDescription)")
        }
    }

    private func loadSessions() {
        do {
            try dbQueue.read { db in
                let loadedSessions = try TrainingSession.fetchAll(db)
                print("Loaded \(loadedSessions.count) sessions")

                for var session in loadedSessions {
                    session.exercises = try Exercise.filter(Exercise.Columns.sessionId == session.id).fetchAll(db)
                    for i in 0..<session.exercises.count {
                        session.exercises[i].sets = try ExerciseSet.filter(ExerciseSet.Columns.exerciseId == session.exercises[i].id).fetchAll(db)
                    }
                }

                DispatchQueue.main.async {
                    self.sessions = loadedSessions.sorted(by: { $0.date > $1.date })
                }
            }
        } catch {
            print("Failed to load sessions: \(error.localizedDescription)")
        }
    }

    func addSession(_ session: TrainingSession) {
        do {
            try dbQueue.write { db in
                try session.insert(db)
                for var exercise in session.exercises {
                    exercise.sessionId = session.id
                    try exercise.insert(db)
                    for var set in exercise.sets {
                        set.exerciseId = exercise.id
                        try set.insert(db)
                    }
                }
            }
            DispatchQueue.main.async {
                self.sessions.append(session)
                self.sessions.sort { $0.date > $1.date }
            }
        } catch {
            print("Failed to add session: \(error.localizedDescription)")
        }
    }

    var totalTrainingDays: Int {
        Set(sessions.map { Calendar.current.startOfDay(for: $0.date) }).count
    }

    var totalExercises: Int {
        sessions.reduce(0) { $0 + $1.exercises.count }
    }

    var totalTrainingDuration: Int {
        sessions.reduce(0) { $0 + $1.duration }
    }

    func getHistoryBodyParts() -> [String] {
        let bodyParts = sessions.map { $0.bodyPart }
        return Array(Set(bodyParts)).sorted()
    }

    func getHistoryExercises(for bodyPart: String) -> [String] {
        let exercises = sessions.filter { $0.bodyPart == bodyPart }
                                .flatMap { $0.exercises }
                                .map { $0.name }
        return Array(Set(exercises)).sorted()
    }

    func calculateVolumeOverTimeForBodyPart(_ bodyPart: String) -> [(Date, Double)] {
        let volumeData = sessions
            .filter { $0.bodyPart == bodyPart }
            .map { session -> (Date, Double) in
                let volume = session.exercises.flatMap { $0.sets }
                    .reduce(0.0) { $0 + $1.weight * Double($1.reps) }
                return (session.date, volume)
            }
        return volumeData.sorted { $0.0 < $1.0 }
    }

    func calculateVolumeOverTimeForExercise(_ exercise: String) -> [(Date, Double)] {
        let volumeData = sessions.flatMap { session -> [(Date, Double)] in
            let exerciseVolume = session.exercises
                .filter { $0.name == exercise }
                .flatMap { $0.sets }
                .reduce(0.0) { $0 + $1.weight * Double($1.reps) }
            return exerciseVolume > 0 ? [(session.date, exerciseVolume)] : []
        }
        return volumeData.sorted { $0.0 < $1.0 }
    }
}

struct TrainingSession: Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: UUID
    var date: Date
    var bodyPart: String
    var duration: Int
    var startTime: Date?
    var exercises: [Exercise]

    enum CodingKeys: String, CodingKey {
        case id, date, bodyPart, duration, startTime
    }

    init(id: UUID = UUID(), date: Date, bodyPart: String, exercises: [Exercise] = [], duration: Int = 0, startTime: Date? = nil) {
        self.id = id
        self.date = date
        self.bodyPart = bodyPart
        self.exercises = exercises
        self.duration = duration
        self.startTime = startTime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        bodyPart = try container.decode(String.self, forKey: .bodyPart)
        duration = try container.decode(Int.self, forKey: .duration)
        startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
        exercises = []  // Initialize as empty, to be filled later if needed
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(bodyPart, forKey: .bodyPart)
        try container.encode(duration, forKey: .duration)
        try container.encodeIfPresent(startTime, forKey: .startTime)
    }

    static let databaseTableName = "trainingSession"

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let date = Column(CodingKeys.date)
        static let bodyPart = Column(CodingKeys.bodyPart)
        static let duration = Column(CodingKeys.duration)
        static let startTime = Column(CodingKeys.startTime)
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.date] = date
        container[Columns.bodyPart] = bodyPart
        container[Columns.duration] = duration
        container[Columns.startTime] = startTime
    }
}

struct Exercise: Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: UUID
    var sessionId: UUID?
    var name: String
    var sets: [ExerciseSet]

    init(id: UUID = UUID(), sessionId: UUID? = nil, name: String, sets: [ExerciseSet] = []) {
        self.id = id
        self.sessionId = sessionId
        self.name = name
        self.sets = sets
    }

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let sessionId = Column(CodingKeys.sessionId)
        static let name = Column(CodingKeys.name)
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.sessionId] = sessionId
        container[Columns.name] = name
    }
}

struct ExerciseSet: Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: UUID
    var exerciseId: UUID?
    var weight: Double
    var reps: Int

    init(id: UUID = UUID(), exerciseId: UUID? = nil, weight: Double, reps: Int) {
        self.id = id
        self.exerciseId = exerciseId
        self.weight = weight
        self.reps = reps
    }

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let exerciseId = Column(CodingKeys.exerciseId)
        static let weight = Column(CodingKeys.weight)
        static let reps = Column(CodingKeys.reps)
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.exerciseId] = exerciseId
        container[Columns.weight] = weight
        container[Columns.reps] = reps
    }
}
