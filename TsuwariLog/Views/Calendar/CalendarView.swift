import SwiftUI
import SwiftData

/// カレンダー画面
struct CalendarView: View {
    @Query(sort: \LogEntry.timestamp, order: .reverse) private var entries: [LogEntry]
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMonth: Date = Date()
    let onDateSelected: (Date) -> Void

    private let calendar = Calendar.current
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

    /// 選択月の日付配列を生成
    private var daysInMonth: [Date?] {
        let interval = calendar.dateInterval(of: .month, for: selectedMonth)!
        let firstDay = interval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay)

        // 月の日数
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)!
        let numberOfDays = range.count

        // 先頭の空白
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)

        // 日付を追加
        for day in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                days.append(date)
            }
        }

        return days
    }

    /// 日付ごとの最新気分を取得
    private var moodByDate: [Date: MoodLevel] {
        var result: [Date: MoodLevel] = [:]

        for entry in entries {
            if case .mood(let level) = entry.content {
                let dateKey = calendar.startOfDay(for: entry.timestamp)
                // entriesは新しい順なので、最初に見つかったものが最新
                if result[dateKey] == nil {
                    result[dateKey] = level
                }
            }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 月セレクター
                CalendarMonthSelector(selectedMonth: $selectedMonth)
                    .padding(.horizontal, Design.paddingM)
                    .padding(.vertical, Design.paddingS)

                // 曜日ヘッダー
                HStack(spacing: 0) {
                    ForEach(weekdays, id: \.self) { weekday in
                        Text(weekday)
                            .font(.appCaption())
                            .foregroundStyle(weekday == "日" ? Color.red.opacity(0.8) : (weekday == "土" ? Color.blue.opacity(0.8) : Color.textSecondary))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, Design.paddingS)
                .padding(.bottom, Design.paddingS)

                // カレンダーグリッド
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                    ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                        if let date = date {
                            CalendarDayCell(
                                date: date,
                                mood: moodByDate[calendar.startOfDay(for: date)],
                                isToday: calendar.isDateInToday(date),
                                onTap: {
                                    onDateSelected(date)
                                    dismiss()
                                }
                            )
                        } else {
                            Color.clear
                                .frame(height: 56)
                        }
                    }
                }
                .padding(.horizontal, Design.paddingS)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("カレンダー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.textPrimary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("今日") {
                        withAnimation {
                            selectedMonth = Date()
                        }
                    }
                    .font(.appBody())
                    .foregroundStyle(Color.primaryBlue)
                }
            }
        }
    }
}

// MARK: - 月セレクター

struct CalendarMonthSelector: View {
    @Binding var selectedMonth: Date

    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年 M月"
        return formatter.string(from: selectedMonth)
    }

    var body: some View {
        HStack {
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(monthYearText)
                .font(.appHeadline())
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 44, height: 44)
            }
        }
    }

    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            withAnimation(Design.standardAnimation) {
                selectedMonth = newMonth
            }
        }
    }
}

// MARK: - 日付セル

struct CalendarDayCell: View {
    let date: Date
    let mood: MoodLevel?
    let isToday: Bool
    let onTap: () -> Void

    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }

    private var weekday: Int {
        Calendar.current.component(.weekday, from: date)
    }

    private var dayColor: Color {
        if weekday == 1 { return Color.red.opacity(0.8) }  // 日曜
        if weekday == 7 { return Color.blue.opacity(0.8) }  // 土曜
        return Color.textPrimary
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // 日付
                Text("\(dayNumber)")
                    .font(.appBody())
                    .foregroundStyle(dayColor)

                // 気分アイコン
                if let mood = mood {
                    Image(mood.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                } else {
                    Color.clear
                        .frame(width: 24, height: 24)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isToday ? Color.primaryBlue.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday ? Color.primaryBlue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LogEntry.self, configurations: config)
    return CalendarView { _ in }
        .modelContainer(container)
}
