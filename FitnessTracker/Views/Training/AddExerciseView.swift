import SwiftUI

struct AddExerciseView: View {
    @EnvironmentObject var trainingData: TrainingData
    @Binding var exercises: [Exercise]
    @Binding var isPresented: Bool
    @Binding var newlyAddedExercise: Exercise?
    @State private var newExerciseName = ""
    let bodyPart: String
    @AppStorage("preferredWeightUnit") private var preferredWeightUnit = "kg"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("新动作")) {
                    TextField("动作名称", text: $newExerciseName)
                    Button("添加动作") {
                        addExercise(name: newExerciseName)
                    }
                }
                
                Section(header: Text("历史动作")) {
                    ForEach(trainingData.getHistoryExercises(for: bodyPart), id: \.self) { exerciseName in
                        Button(action: {
                            addExercise(name: exerciseName)
                        }) {
                            HStack {
                                Text(exerciseName).foregroundColor(.primary)
                                Spacer()
                                if let weightRange = trainingData.getLastTrainingWeightRange(for: exerciseName) {
                                    Text("上次重量：\(formatWeight(weightRange.min))-\(formatWeight(weightRange.max)) \(preferredWeightUnit)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("添加新动作")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func addExercise(name: String) {
        if !name.isEmpty {
            let newExercise = Exercise(name: name, sets: [])
            exercises.append(newExercise)
            newlyAddedExercise = newExercise
            isPresented = false
        }
    }
    
    private func formatWeight(_ weight: Double) -> String {
        return String(format: "%.1f", weight)
    }
}
