import SwiftUI

struct SessionDetailView: View {
    @EnvironmentObject var trainingData: TrainingData
    @StateObject private var viewModel: SessionViewModel
    @State private var showingAddExercise = false
    @State private var showingDeleteAlert = false
    @State private var isEditing = false
    @State private var selectedExercise: Exercise?
    @Environment(\.presentationMode) var presentationMode
    var onDelete: () -> Void

    init(session: TrainingSession, onDelete: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: SessionViewModel(session: session))
        self.onDelete = onDelete
    }

    var body: some View {
        List {
            Section(header: Text("训练信息")) {
                if isEditing {
                    DatePicker("日期", selection: $viewModel.date, displayedComponents: .date)
                    HStack {
                        Text("训练部位")
                        TextField("", text: $viewModel.bodyPart)
                    }
                    HStack {
                        Text("时长（分钟）")
                        TextField("", value: $viewModel.duration, format: .number)
                            .keyboardType(.numberPad)
                    }
                } else {
                    Text("日期: \(viewModel.date, style: .date)")
                    Text("训练部位: \(viewModel.bodyPart)")
                    Text("时长: \(viewModel.duration) 分钟")
                }
            }

            Section(header: Text("训练动作")) {
                ForEach($viewModel.exercises) { $exercise in
                    Button(action: {
                        selectedExercise = exercise
                    }) {
                        HStack{
                            Text(exercise.name.isEmpty ? "未命名动作" : exercise.name)
                                .foregroundColor(.primary)
                            Spacer()
                            if exercise.sets.count >= 1 {
                                Text("\(exercise.sets.count) 组")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteExercise)

                Button(action: {
                    showingAddExercise = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("添加新动作")
                    }
                }
                .foregroundColor(.blue)
            }

            Section {
                Button("删除该训练记录") {
                    showingDeleteAlert = true
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("训练详情")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "保存" : "编辑") {
                    isEditing.toggle()
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView(
                exercises: $viewModel.exercises,
                isPresented: $showingAddExercise,
                newlyAddedExercise: $selectedExercise,
                bodyPart: viewModel.bodyPart
            )
        }
        .sheet(item: $selectedExercise) { exercise in
            if let index = viewModel.exercises.firstIndex(where: { $0.id == exercise.id }) {
                NavigationView {
                    ExerciseDetailView(
                        exercise: $viewModel.exercises[index],
                        lastExerciseTime: $viewModel.lastExerciseTime,
                        sessionDuration: $viewModel.duration
                    )
                    .navigationTitle(exercise.name.isEmpty ? "新动作" : exercise.name)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("完成") {
                                viewModel.updateDuration()
                                selectedExercise = nil
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if viewModel.lastExerciseTime == nil {
                viewModel.lastExerciseTime = viewModel.date
            }
        }
        .onDisappear {
            saveChanges()
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("确认删除"),
                message: Text("您确定要删除这个训练记录吗？此操作不可撤销。"),
                primaryButton: .destructive(Text("删除")) {
                    onDelete()
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func deleteExercise(at offsets: IndexSet) {
        viewModel.exercises.remove(atOffsets: offsets)
    }

    private func saveChanges() {
        if let index = trainingData.sessions.firstIndex(where: { $0.id == viewModel.id }) {
            trainingData.sessions[index] = TrainingSession(
                id: viewModel.id,
                date: viewModel.date,
                bodyPart: viewModel.bodyPart,
                exercises: viewModel.exercises,
                duration: max(0, viewModel.duration),
                startTime: viewModel.lastExerciseTime
            )
        }
    }
}

class SessionViewModel: ObservableObject {
    let id: UUID
    @Published var date: Date
    @Published var bodyPart: String
    @Published var exercises: [Exercise]
    @Published var duration: Int
    @Published var lastExerciseTime: Date?

    init(session: TrainingSession) {
        self.id = session.id
        self.date = session.date
        self.bodyPart = session.bodyPart
        self.exercises = session.exercises
        self.duration = session.duration
        self.lastExerciseTime = session.startTime
    }

    func updateDuration() {
        let now = Date()
        if let lastTime = lastExerciseTime {
            let newDuration = duration + max(0, Int(now.timeIntervalSince(lastTime) / 60))
            duration = max(0, newDuration)  // Ensure duration is non-negative
        }
        lastExerciseTime = now
    }

    func resetDuration() {
        duration = 0
        lastExerciseTime = date
    }
}
