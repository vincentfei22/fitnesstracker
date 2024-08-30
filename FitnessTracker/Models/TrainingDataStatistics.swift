import Foundation

extension TrainingData {
    // MARK: - Statistics
    
    var totalTrainingDays: Int {
        Set(sessions.map { Calendar.current.startOfDay(for: $0.date) }).count
    }
    
    var totalExercises: Int {
        sessions.reduce(0) { $0 + $1.exercises.count }
    }
    
    var totalTrainingDuration: Int {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    // MARK: - Analysis
    
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
