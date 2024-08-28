import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .system: return "系统"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }
}

struct SettingsView: View {
    @AppStorage("preferredWeightUnit") private var preferredWeightUnit = "kg"
    @AppStorage("appTheme") private var appTheme = AppTheme.system
    @EnvironmentObject var trainingData: TrainingData

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("偏好设置")) {
                    Picker("重量单位", selection: $preferredWeightUnit) {
                        Text("公斤 (kg)").tag("kg")
                        Text("磅 (lbs)").tag("lbs")
                    }
                }

                Section(header: Text("外观")) {
                    Picker("主题", selection: $appTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                }

                Section(header: Text("使用统计")) {
                    HStack {
                        Text("训练记录总数")
                        Spacer()
                        Text("\(trainingData.sessions.count)")
                    }
                    HStack {
                        Text("总训练天数")
                        Spacer()
                        Text("\(trainingData.totalTrainingDays)")
                    }
                    HStack {
                        Text("总训练动作数")
                        Spacer()
                        Text("\(trainingData.totalExercises)")
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}
