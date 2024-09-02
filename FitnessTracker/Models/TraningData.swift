import Foundation

class TrainingData: ObservableObject {
    @Published var sessions: [TrainingSession] {
        didSet {
            saveSessions()
        }
    }

    private let fileManager = FileManager.default
    private lazy var sessionsURL: URL = {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("trainingSessions.plist")
    }()

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
            let data = try PropertyListEncoder().encode(sessions)
            try data.write(to: sessionsURL)
        } catch {
            print("Failed to save sessions: \(error.localizedDescription)")
        }
    }

    private func loadSessions() {
        guard fileManager.fileExists(atPath: sessionsURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: sessionsURL)
            sessions = try PropertyListDecoder().decode([TrainingSession].self, from: data)
            sortSessions()
        } catch {
            print("Failed to load sessions: \(error.localizedDescription)")
        }
    }
    func getLastTrainingWeightRange(for exercise: String) -> (min: Double, max: Double)? {
        // 按日期降序排序会话，找到包含该动作的最近一次训练
        guard let lastSession = sessions.sorted(by: { $0.date > $1.date })
            .first(where: { session in
                session.exercises.contains { $0.name == exercise }
            }),
            let lastExercise = lastSession.exercises.first(where: { $0.name == exercise }),
            !lastExercise.sets.isEmpty else {
            return nil
        }
        
        let weights = lastExercise.sets.map { $0.weight }
        return (min: weights.min() ?? 0, max: weights.max() ?? 0)
    }
}
