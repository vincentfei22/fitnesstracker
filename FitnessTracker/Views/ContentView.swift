import SwiftUI

struct ContentView: View {
    @EnvironmentObject var trainingData: TrainingData
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TrainingLogView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("记录")
                }
                .tag(0)
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("统计")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
                .tag(2)
        }
    }
}
