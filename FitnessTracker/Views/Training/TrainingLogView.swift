import SwiftUI

struct TrainingLogView: View {
    @EnvironmentObject var trainingData: TrainingData
    @State private var showingAddSession = false
    @State private var selectedSession: TrainingSession?
    @State private var filterBodyPart: String? // 新增：用于存储筛选的部位

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredSessions) { session in
                    Button(action: {
                        selectedSession = session
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(session.date, style: .date)
                                    .font(.headline)
                                Text(session.bodyPart)
                                    .font(.subheadline)
                            }
                            Spacer()
                            if session.exercises.count >= 1 {
                                Text("\(session.exercises.count) 个动作")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("训练记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("全部") {
                            filterBodyPart = nil
                        }
                        ForEach(trainingData.getHistoryBodyParts(), id: \.self) { part in
                            Button(part) {
                                filterBodyPart = part
                            }
                        }
                    } label: {
                        Label("筛选", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSession = true
                    }) {
                        Image(systemName: "plus")
                    }
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

    // 用于筛选会话的计算属性
    private var filteredSessions: [TrainingSession] {
        if let bodyPart = filterBodyPart {
            return trainingData.sessions.filter { $0.bodyPart == bodyPart }
        } else {
            return trainingData.sessions
        }
    }
}
