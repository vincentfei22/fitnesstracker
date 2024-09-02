import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var trainingData: TrainingData
    @State private var selectedBodyPart: String = ""
    @State private var selectedExercise: String = ""
    @State private var chartData: [(Date, Double)] = []
    @AppStorage("preferredWeightUnit") private var preferredWeightUnit = "kg"
    
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    HStack {
                        Picker("Body Part", selection: $selectedBodyPart) {
                            Text("选择部位").tag("")
                            ForEach(trainingData.getHistoryBodyParts(), id: \.self) { bodyPart in
                                Text(bodyPart).tag(bodyPart)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedBodyPart) { _ in
                            selectedExercise = ""
                            updateChartData()
                        }

                        Picker("Exercise", selection: $selectedExercise) {
                            Text("总容量(\(preferredWeightUnit))").tag("")
                            if !selectedBodyPart.isEmpty {
                                ForEach(trainingData.getHistoryExercises(for: selectedBodyPart), id: \.self) { exercise in
                                    Text(exercise).tag(exercise)
                                }
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .disabled(selectedBodyPart.isEmpty)
                        .onChange(of: selectedExercise) { _ in
                            updateChartData()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    .background(Color(UIColor.systemBackground))

                    if !selectedBodyPart.isEmpty && !chartData.isEmpty {
                        ScrollableVolumeChart(
                            data: chartData,
                            availableHeight: geometry.size.height - 100,
                            availableWidth: geometry.size.width
                        )
                    } else {
                        Text("请选择一个训练部位和动作来查看统计数据")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .navigationTitle("统计")
            .onAppear {
                updateChartData()
            }
        }
    }

    private func updateChartData() {
        if selectedBodyPart.isEmpty {
            chartData = []
        } else if selectedExercise.isEmpty {
            chartData = trainingData.calculateVolumeOverTimeForBodyPart(selectedBodyPart)
        } else {
            chartData = trainingData.calculateVolumeOverTimeForExercise(selectedExercise)
        }
    }
}

struct ScrollableVolumeChart: View {
    let data: [(Date, Double)]
    let availableHeight: CGFloat
    let availableWidth: CGFloat

    private var chartWidth: CGFloat {
        max(availableWidth * 1.5, CGFloat(data.count + 2) * 70)  // Add space for two extra data points
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Chart {
                ForEach(data, id: \.0) { item in
                    LineMark(
                        x: .value("Date", item.0),
                        y: .value("Volume", item.1)
                    )
                    PointMark(
                        x: .value("Date", item.0),
                        y: .value("Volume", item.1)
                    )
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self),
                       data.contains(where: { Calendar.current.isDate($0.0, inSameDayAs: date) }) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text(date.formatted(.dateTime.month().day()))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                        }
                    }
                }
            }
            .chartXScale(
                domain: ClosedRange(
                    uncheckedBounds: (
                        lower: Calendar.current.date(byAdding: .day, value: -3, to: data.first?.0 ?? Date()) ?? Date(),
                        upper: Calendar.current.date(byAdding: .day, value: 3, to: data.last?.0 ?? Date()) ?? Date()
                    )
                )
            )
            .chartYScale(domain: .automatic(includesZero: false))
            .frame(width: chartWidth, height: availableHeight - 40)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .frame(height: availableHeight)
    }
}
