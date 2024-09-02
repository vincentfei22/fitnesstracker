import SwiftUI

struct AddSessionView: View {
    @EnvironmentObject var trainingData: TrainingData
    @Binding var isPresented: Bool
    @Binding var newlyAddedSession: TrainingSession?
    @State private var date = Date()
    @State private var bodyPart = ""
    @State private var startTime = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                    TextField("训练部位", text: $bodyPart)
                }
                
                Section(header: Text("历史训练部位")) {
                    HistoryBodyPartsList(selectedBodyPart: $bodyPart).foregroundColor(.primary)
                }
            }
            .navigationTitle("新训练")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveSession()
                    }
                }
            }
        }
    }
    
    private func saveSession() {
        let newSession = TrainingSession(
            date: date,
            bodyPart: bodyPart,
            startTime: date
        )
        trainingData.addSession(newSession)
        newlyAddedSession = newSession
        isPresented = false
    }
}

struct HistoryBodyPartsList: View {
    @EnvironmentObject var trainingData: TrainingData
    @Binding var selectedBodyPart: String

    var body: some View {
        ForEach(trainingData.getHistoryBodyParts(), id: \.self) { part in
            Button(action: {
                selectedBodyPart = part
            }) {
                Text(part)
            }
        }
    }
}
