import Foundation
import CoreData

// MARK: - TrainingSession Extensions

extension TrainingSession {
    var exerciseArray: [Exercise] {
        let set = exercises as? Set<Exercise> ?? []
        return Array(set).sorted { $0.name < $1.name }
    }
    
    var totalVolume: Double {
        exerciseArray.reduce(0) { $0 + $1.totalVolume }
    }
}

// MARK: - Exercise Extensions

extension Exercise {
    var setArray: [ExerciseSet] {
        let set = sets as? Set<ExerciseSet> ?? []
        return Array(set).sorted { $0.weight > $1.weight }
    }
    
    var totalVolume: Double {
        setArray.reduce(0) { $0 + $1.volume }
    }
}

// MARK: - ExerciseSet Extensions

extension ExerciseSet {
    var volume: Double {
        Double(weight) * Double(reps)
    }
}
