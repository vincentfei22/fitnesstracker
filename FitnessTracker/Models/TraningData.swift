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
}
