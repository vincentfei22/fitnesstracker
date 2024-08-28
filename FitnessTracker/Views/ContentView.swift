import SwiftUI

struct ContentView: View {
    @EnvironmentObject var trainingData: TrainingData
    @State private var selectedTab = 0
    @AppStorage("appTheme") private var appTheme = AppTheme.system

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
        .preferredColorScheme(colorScheme)
    }

    private var colorScheme: ColorScheme? {
        switch appTheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
