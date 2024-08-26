import SwiftUI

struct ContentView: View {
    @EnvironmentObject var trainingData: TrainingData
    @State private var showingAddSession = false
    @State private var selectedSession: TrainingSession?

    var body: some View {
        NavigationView {
            List {
                ForEach(trainingData.sessions) { session in
                    Button(action: {
                        selectedSession = session
                    }) {
                        VStack(alignment: .leading) {
                            Text(session.date, style: .date)
                                .font(.headline)
                            Text(session.bodyPart)
                                .font(.subheadline)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("训练记录")
            .toolbar {
                Button(action: {
                    showingAddSession = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddSession) {
                AddSessionView(isPresented: $showingAddSession, newlyAddedSession: $selectedSession)
            }
            .sheet(item: $selectedSession) { session in
                NavigationView {
                    SessionDetailView(
                        session: session,
                        onDelete: {
                            if let index = trainingData.sessions.firstIndex(where: { $0.id == session.id }) {
                                trainingData.sessions.remove(at: index)
                            }
                            selectedSession = nil
                        }
                    )
                    .navigationTitle("训练详情")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("完成") {
                                selectedSession = nil
                            }
                        }
                    }
                }
            }
        }
    }
}
