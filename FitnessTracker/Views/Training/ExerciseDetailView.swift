import SwiftUI

struct ExerciseDetailView: View {
    @Binding var exercise: Exercise
    @State private var newWeight: String = ""
    @State private var newReps: String = ""
    @FocusState private var focusedField: Field?
    @AppStorage("preferredWeightUnit") private var preferredWeightUnit = "kg"

    enum Field {
        case exerciseName, newWeight, newReps
    }

    var body: some View {
        Form {
            Section(header: Text("动作信息")) {
                TextField("动作名称", text: $exercise.name)
                    .focused($focusedField, equals: .exerciseName)
            }

            if !exercise.sets.isEmpty {
                Section(header: Text("已完成的组")) {
                    ForEach(exercise.sets.indices, id: \.self) { index in
                        HStack {
                            Text("组 \(index + 1):")
                            Spacer()
                            Text("\(exercise.sets[index].weight, specifier: "%.1f") \(preferredWeightUnit)")
                            Text("\(exercise.sets[index].reps) 次")
                        }
                    }
                    .onDelete(perform: deleteSets)
                }
            }

            Section(header: Text(exercise.sets.isEmpty ? "添加第一组" : "添加新的组")) {
                TextField("重量 (\(preferredWeightUnit))", text: $newWeight)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .newWeight)
                TextField("次数", text: $newReps)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .newReps)

                Button(exercise.sets.isEmpty ? "添加第一组" : "添加组") {
                    if let weight = Double(newWeight), let reps = Int(newReps) {
                        exercise.sets.append(ExerciseSet(weight: weight, reps: reps))
                        newWeight = ""
                        newReps = ""
                        focusedField = .newWeight
                    }
                }
            }
        }
        .navigationTitle(exercise.name.isEmpty ? "新动作" : exercise.name)
    }

    private func deleteSets(at offsets: IndexSet) {
        exercise.sets.remove(atOffsets: offsets)
    }
}
