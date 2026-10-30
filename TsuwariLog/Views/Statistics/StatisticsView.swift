import SwiftUI
import SwiftData
import Charts

/// 表示モード
enum StatisticsViewMode: String, CaseIterable {
    case month = "月"
    case week = "週数"
}

/// 統計画面（まとめ）
struct StatisticsView: View {
    @Query(sort: \LogEntry.timestamp, order: .forward) private var allEntries: [LogEntry]
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settings = UserSettings.shared

    @State private var viewMode: StatisticsViewMode = .month
    @State private var selectedMonth: Date = Date()
    @State private var selectedWeek: Int = 0  // 妊娠週数

    /// 選択中の期間のエントリーをフィルタ
    private var filteredEntries: [LogEntry] {
        switch viewMode {
        case .month:
            let calendar = Calendar.current
            return allEntries.filter { entry in
                calendar.isDate(entry.timestamp, equalTo: selectedMonth, toGranularity: .month)
            }
        case .week:
            return entriesForWeek(selectedWeek)
        }
    }

    /// 指定した妊娠週のエントリーを取得
    private func entriesForWeek(_ week: Int) -> [LogEntry] {
        guard let dueDate = settings.dueDate else { return [] }

        let calendar = Calendar.current
        // 最終月経開始日 = 出産予定日 - 280日
        let lastMenstrualDate = calendar.date(byAdding: .day, value: -280, to: dueDate)!

        // 指定週の開始日と終了日
        let weekStart = calendar.date(byAdding: .day, value: week * 7, to: lastMenstrualDate)!
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!

        return allEntries.filter { entry in
            entry.timestamp >= weekStart && entry.timestamp < weekEnd
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Design.paddingL) {
                    // モード切替
                    Picker("表示モード", selection: $viewMode) {
                        ForEach(StatisticsViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Design.paddingM)

                    // セレクター（モードに応じて切替）
                    if viewMode == .month {
                        MonthSelector(selectedMonth: $selectedMonth)
                            .padding(.horizontal, Design.paddingM)
                    } else {
                        WeekSelector(selectedWeek: $selectedWeek, settings: settings)
                            .padding(.horizontal, Design.paddingM)
                    }

                    // カテゴリ別カード（メモ以外の6種類）
                    VStack(spacing: Design.paddingM) {
                        // 気分
                        MoodSummaryCard(entries: filteredEntries)

                        // 症状
                        SymptomSummaryCard(entries: filteredEntries)

                        // 食べられた
                        FoodSummaryCard(entries: filteredEntries)

                        // 体重
                        WeightSummaryCard(entries: filteredEntries)

                        // 水分
                        HydrationSummaryCard(entries: filteredEntries)

                        // 通院・健診
                        ClinicSummaryCard(entries: filteredEntries)
                    }
                    .padding(.horizontal, Design.paddingM)
                }
                .padding(.vertical, Design.paddingL)
            }
            .background(Color.appBackground)
            .navigationTitle("まとめ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.textPrimary)
                    }
                }
            }
            .onAppear {
                // 現在の妊娠週数を初期値に
                if let week = settings.pregnancyWeek {
                    selectedWeek = week.weeks
                }
            }
        }
    }
}

// MARK: - 月セレクター

struct MonthSelector: View {
    @Binding var selectedMonth: Date

    private var monthText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月"
        return formatter.string(from: selectedMonth)
    }

    private var yearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年"
        return formatter.string(from: selectedMonth)
    }

    var body: some View {
        HStack {
            // 前月ボタン
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            // 月表示
            VStack(spacing: 2) {
                Text(yearText)
                    .font(.appCaption())
                    .foregroundStyle(Color.textSecondary)
                Text(monthText)
                    .font(.appTitle(24))
                    .foregroundStyle(Color.textPrimary)
            }

            Spacer()

            // 次月ボタン
            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.vertical, Design.paddingS)
    }

    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            withAnimation(Design.standardAnimation) {
                selectedMonth = newMonth
            }
        }
    }
}

// MARK: - 週数セレクター

struct WeekSelector: View {
    @Binding var selectedWeek: Int
    let settings: UserSettings

    private var currentWeek: Int {
        settings.pregnancyWeek?.weeks ?? 0
    }

    private var weekText: String {
        "\(selectedWeek)週"
    }

    private var monthText: String {
        let month = (selectedWeek / 4) + 1
        return "\(month)ヶ月"
    }

    var body: some View {
        if settings.dueDate != nil {
            HStack {
                // 前週ボタン
                Button(action: { changeWeek(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(selectedWeek > 0 ? Color.textPrimary : Color.textTertiary)
                        .frame(width: 44, height: 44)
                }
                .disabled(selectedWeek <= 0)

                Spacer()

                // 週数表示
                VStack(spacing: 2) {
                    Text(monthText)
                        .font(.appCaption())
                        .foregroundStyle(Color.textSecondary)
                    Text(weekText)
                        .font(.appTitle(24))
                        .foregroundStyle(Color.textPrimary)
                }

                Spacer()

                // 次週ボタン
                Button(action: { changeWeek(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(selectedWeek < 42 ? Color.textPrimary : Color.textTertiary)
                        .frame(width: 44, height: 44)
                }
                .disabled(selectedWeek >= 42)
            }
            .padding(.vertical, Design.paddingS)
        } else {
            // 出産予定日未設定の場合
            VStack(spacing: Design.paddingS) {
                Text("出産予定日が設定されていません")
                    .font(.appBody())
                    .foregroundStyle(Color.textSecondary)
                Text("設定画面から出産予定日を設定してください")
                    .font(.appCaption())
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(.vertical, Design.paddingL)
        }
    }

    private func changeWeek(by value: Int) {
        let newWeek = selectedWeek + value
        if newWeek >= 0 && newWeek <= 42 {
            withAnimation(Design.standardAnimation) {
                selectedWeek = newWeek
            }
        }
    }
}

// MARK: - カード共通ヘッダー

struct SummaryCardHeader: View {
    let category: RecordCategory
    let count: Int

    var body: some View {
        HStack(spacing: Design.paddingS) {
            // カテゴリアイコン
            CategoryIcon(category: category, size: .small)

            VStack(alignment: .leading, spacing: 2) {
                Text(category.title)
                    .font(.appHeadline())
                    .foregroundStyle(Color.textPrimary)
                Text("\(count)件の記録")
                    .font(.appCaption())
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
    }
}

// MARK: - 気分サマリーカード

struct MoodSummaryCard: View {
    let entries: [LogEntry]

    private var moodCounts: [MoodLevel: Int] {
        var counts: [MoodLevel: Int] = [:]
        for entry in entries {
            if case .mood(let level) = entry.content {
                counts[level, default: 0] += 1
            }
        }
        return counts
    }

    private var totalCount: Int {
        moodCounts.values.reduce(0, +)
    }

    private var hasData: Bool { totalCount > 0 }

    // 気分の色
    private func colorForMood(_ mood: MoodLevel) -> Color {
        switch mood {
        case .veryGood: return Color(hex: "4CAF7A") // 緑
        case .good: return Color(hex: "8BC34A")     // 黄緑
        case .normal: return Color(hex: "FFC107")   // 黄
        case .bad: return Color(hex: "FF9800")      // オレンジ
        case .veryBad: return Color(hex: "F44336")  // 赤
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Design.paddingM) {
            SummaryCardHeader(category: .mood, count: totalCount)

            if hasData {
                // 気分分布（横棒グラフ風）
                VStack(spacing: Design.paddingS) {
                    ForEach(MoodLevel.allCases.reversed(), id: \.self) { mood in
                        HStack(spacing: Design.paddingS) {
                            // 顔アイコン
                            Image(mood.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)

                            // バー
                            GeometryReader { geo in
                                let count = moodCounts[mood] ?? 0
                                let ratio = totalCount > 0 ? CGFloat(count) / CGFloat(totalCount) : 0
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(colorForMood(mood))
                                    .frame(width: geo.size.width * ratio)
                            }
                            .frame(height: 20)

                            // 回数
                            Text("\(moodCounts[mood] ?? 0)")
                                .font(.appCaption())
                                .foregroundStyle(Color.textSecondary)
                                .frame(width: 30, alignment: .trailing)
                        }
                    }
                }
            } else {
                EmptySummaryPlaceholder(message: "記録がありません")
            }
        }
        .padding(Design.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: Design.cardRadius)
                .fill(Color.cardBackground)
        )
    }
}

// MARK: - 症状サマリーカード

struct SymptomSummaryCard: View {
    let entries: [LogEntry]

    /// 症状ごとの回数（「その他」は自由記述の内容ごとに集計）
    private var symptomCounts: [(label: String, count: Int)] {
        var counts: [String: Int] = [:]
        for entry in entries {
            if case .symptom(let types, let otherText) = entry.content {
                for type in types {
                    if type == .other, let text = otherText, !text.isEmpty {
                        counts[text, default: 0] += 1
                    } else {
                        counts[type.rawValue, default: 0] += 1
                    }
                }
            }
        }
        return counts
            .map { (label: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count || ($0.count == $1.count && $0.label < $1.label) }
    }

    private var totalCount: Int {
        entries.filter { entry in
            if case .symptom = entry.content { return true }
            return false
        }.count
    }

    private var hasData: Bool { !symptomCounts.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: Design.paddingM) {
            SummaryCardHeader(category: .symptom, count: totalCount)

            if hasData {
                // 症状リスト（最大5件表示）
                VStack(spacing: Design.paddingS) {
                    ForEach(symptomCounts.prefix(5), id: \.label) { item in
                        HStack {
                            Text(item.label)
                                .font(.appBody())
                                .foregroundStyle(Color.textPrimary)

                            Spacer()

                            Text("\(item.count)回")
                                .font(.appBody())
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            } else {
                EmptySummaryPlaceholder(message: "記録がありません")
            }
        }
        .padding(Design.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: Design.cardRadius)
                .fill(Color.cardBackground)
        )
    }
}

// MARK: - 食べられたサマリーカード

struct FoodSummaryCard: View {
    let entries: [LogEntry]

    private var foodCounts: [(food: FoodItem, count: Int)] {
        var counts: [FoodItem: Int] = [:]
        for entry in entries {
            if case .food(let items, _) = entry.content {
                for item in items {
                    counts[item, default: 0] += 1
                }
            }
        }
        return counts
            .map { (food: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    private var totalCount: Int {
        entries.filter { entry in
            if case .food = entry.content { return true }
            return false
        }.count
    }

    private var hasData: Bool { !foodCounts.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: Design.paddingM) {
            SummaryCardHeader(category: .food, count: totalCount)

            if hasData {
                // 食べ物アイコングリッド
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Design.paddingS), count: 4), spacing: Design.paddingS) {
                    ForEach(foodCounts.prefix(8), id: \.food) { item in
                        VStack(spacing: 4) {
                            Image(item.food.customImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)

                            Text("\(item.count)")
                                .font(.appCaption())
                                .foregroundStyle(Color.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Design.paddingS)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.foodPastel.opacity(0.5))
                        )
                    }
                }
            } else {
                EmptySummaryPlaceholder(message: "記録がありません")
            }
        }
        .padding(Design.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: Design.cardRadius)
                .fill(Color.cardBackground)
        )
    }
}

// MARK: - 体重サマリーカード

struct WeightSummaryCard: View {
    let entries: [LogEntry]

    private var weightData: [(date: Date, value: Double)] {
        entries.compactMap { entry in
            if case .weight(let value) = entry.content {
                return (date: entry.timestamp, value: value)
            }
            return nil
        }.sorted { $0.date < $1.date }
    }

    private var hasData: Bool { !weightData.isEmpty }

    private var minWeight: Double {
        (weightData.map { $0.value }.min() ?? 40) - 1
    }

    private var maxWeight: Double {
        (weightData.map { $0.value }.max() ?? 80) + 1
    }

    private var latestWeight: Double? {
        weightData.last?.value
    }

    private var weightChange: Double? {
        guard weightData.count >= 2 else { return nil }
        return weightData.last!.value - weightData.first!.value
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Design.paddingM) {
            SummaryCardHeader(category: .weight, count: weightData.count)

            if hasData {
                // 現在の体重と変化
                HStack(alignment: .lastTextBaseline, spacing: Design.paddingS) {
                    if let weight = latestWeight {
                        Text(String(format: "%.1f", weight))
                            .font(.appLargeNumber())
                            .foregroundStyle(Color.textPrimary)
                        Text("kg")
                            .font(.appBody())
                            .foregroundStyle(Color.textSecondary)
                    }

                    Spacer()

                    if let change = weightChange {
                        HStack(spacing: 4) {
                            Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                .font(.system(size: 12))
                            Text(String(format: "%+.1f kg", change))
                                .font(.appBody())
                        }
                        .foregroundStyle(change >= 0 ? Color(hex: "F44336") : Color(hex: "4CAF7A"))
                    }
                }

                // グラフ
                Chart(weightData, id: \.date) { item in
                    LineMark(
                        x: .value("日付", item.date, unit: .day),
                        y: .value("体重", item.value)
                    )
                    .foregroundStyle(Color(hex: "4CAF7A"))
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    PointMark(
                        x: .value("日付", item.date, unit: .day),
                        y: .value("体重", item.value)
                    )
                    .foregroundStyle(Color(hex: "4CAF7A"))
                    .symbolSize(30)
                }
                .chartYScale(domain: minWeight...maxWeight)
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                            .foregroundStyle(Color.textTertiary)
                        AxisValueLabel {
                            if let weight = value.as(Double.self) {
                                Text("\(weight, specifier: "%.0f")")
                                    .font(.caption2)
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                            .foregroundStyle(Color.textTertiary)
                        AxisValueLabel(format: .dateTime.day())
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .frame(height: 150)
            } else {
                EmptySummaryPlaceholder(message: "記録がありません")
            }
        }
        .padding(Design.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: Design.cardRadius)
                .fill(Color.cardBackground)
        )
    }
}

// MARK: - 水分サマリーカード

struct HydrationSummaryCard: View {
    let entries: [LogEntry]

    private var hydrationData: [(date: Date, amount: Int)] {
        entries.compactMap { entry in
            if case .hydration(let amount) = entry.content {
                return (date: entry.timestamp, amount: amount)
            }
            return nil
        }
    }

    private var totalAmount: Int {
        hydrationData.reduce(0) { $0 + $1.amount }
    }

    private var dailyAverage: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(hydrationData.map { calendar.startOfDay(for: $0.date) })
        guard !uniqueDays.isEmpty else { return 0 }
        return totalAmount / uniqueDays.count
    }

    private var hasData: Bool { !hydrationData.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: Design.paddingM) {
            SummaryCardHeader(category: .hydration, count: hydrationData.count)

            if hasData {
                HStack(spacing: Design.paddingL) {
                    // 合計
                    VStack(alignment: .leading, spacing: 4) {
                        Text("合計")
                            .font(.appCaption())
                            .foregroundStyle(Color.textSecondary)
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(totalAmount)")
                                .font(.appTitle(28))
                                .foregroundStyle(Color.textPrimary)
                            Text("ml")
                                .font(.appBody())
                                .foregroundStyle(Color.textSecondary)
                        }
                    }

                    Spacer()

                    // 1日平均
                    VStack(alignment: .leading, spacing: 4) {
                        Text("1日平均")
                            .font(.appCaption())
                            .foregroundStyle(Color.textSecondary)
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(dailyAverage)")
                                .font(.appTitle(28))
                                .foregroundStyle(Color.textPrimary)
                            Text("ml")
                                .font(.appBody())
                                .foregroundStyle(Color.textSecondary)
                        }
                    }

                    Spacer()
                }
            } else {
                EmptySummaryPlaceholder(message: "記録がありません")
            }
        }
        .padding(Design.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: Design.cardRadius)
                .fill(Color.cardBackground)
        )
    }
}

// MARK: - 通院・健診サマリーカード

struct ClinicSummaryCard: View {
    let entries: [LogEntry]

    private var clinicEntries: [(date: Date, type: ClinicType, hospitalName: String?)] {
        entries.compactMap { entry in
            if case .clinic(let type, let hospitalName, _, _) = entry.content {
                return (date: entry.timestamp, type: type, hospitalName: hospitalName)
            }
            return nil
        }.sorted { $0.date > $1.date }
    }

    private var hasData: Bool { !clinicEntries.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: Design.paddingM) {
            SummaryCardHeader(category: .clinic, count: clinicEntries.count)

            if hasData {
                VStack(spacing: Design.paddingS) {
                    ForEach(clinicEntries.prefix(5), id: \.date) { item in
                        HStack(spacing: Design.paddingM) {
                            // 日付
                            Text(item.date.monthDayString)
                                .font(.appBody())
                                .foregroundStyle(Color.textSecondary)
                                .frame(width: 50, alignment: .leading)

                            // タイプアイコン
                            Image(item.type.customImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)

                            // タイプ名
                            Text(item.type.rawValue)
                                .font(.appBody())
                                .foregroundStyle(Color.textPrimary)

                            Spacer()

                            // 病院名
                            if let name = item.hospitalName, !name.isEmpty {
                                Text(name)
                                    .font(.appCaption())
                                    .foregroundStyle(Color.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } else {
                EmptySummaryPlaceholder(message: "記録がありません")
            }
        }
        .padding(Design.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: Design.cardRadius)
                .fill(Color.cardBackground)
        )
    }
}

// MARK: - 空のサマリープレースホルダー

struct EmptySummaryPlaceholder: View {
    let message: String

    var body: some View {
        HStack {
            Spacer()
            Text(message)
                .font(.appBody())
                .foregroundStyle(Color.textSecondary)
            Spacer()
        }
        .padding(.vertical, Design.paddingL)
    }
}

// MARK: - MoodLevel Extension

extension MoodLevel {
    var numericValue: Int {
        switch self {
        case .veryBad: return 1
        case .bad: return 2
        case .normal: return 3
        case .good: return 4
        case .veryGood: return 5
        }
    }

    var shortLabel: String {
        switch self {
        case .veryBad: return "😢"
        case .bad: return "😔"
        case .normal: return "😐"
        case .good: return "🙂"
        case .veryGood: return "😊"
        }
    }

    static func fromNumeric(_ value: Int) -> MoodLevel? {
        switch value {
        case 1: return .veryBad
        case 2: return .bad
        case 3: return .normal
        case 4: return .good
        case 5: return .veryGood
        default: return nil
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LogEntry.self, configurations: config)
    return StatisticsView()
        .modelContainer(container)
}
