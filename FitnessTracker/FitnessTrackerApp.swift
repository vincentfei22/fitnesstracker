import SwiftUI
import GRDB

@main
struct FitnessTrackerApp: App {
    @StateObject private var trainingData = TrainingData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(trainingData)
        }
    }
}
