import Foundation

class TrainingData: ObservableObject {
    @Published var sessions: [TrainingSession] {
        didSet {
            saveSessions()
        }
    }
    
    init() {
        self.sessions = []
        loadSessions()
        sortSessions()
    }
    
    func addSession(_ session: TrainingSession) {
        sessions.append(session)
        sortSessions()
    }
    
    private func sortSessions() {
        sessions.sort { $0.date > $1.date }
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
    
    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: "trainingSessions")
        } catch {
            print("Failed to save sessions: \(error.localizedDescription)")
        }
    }
    
    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: "trainingSessions") else { return }
        do {
            sessions = try JSONDecoder().decode([TrainingSession].self, from: data)
            sortSessions()
        } catch {
            print("Failed to load sessions: \(error.localizedDescription)")
        }
    }
}


struct TrainingSession: Identifiable, Codable {
    let id: UUID
    var date: Date
    var bodyPart: String
    var exercises: [Exercise]
    
    init(id: UUID = UUID(), date: Date, bodyPart: String, exercises: [Exercise]) {
        self.id = id
        self.date = date
        self.bodyPart = bodyPart
        self.exercises = exercises
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

extension TrainingData {
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
