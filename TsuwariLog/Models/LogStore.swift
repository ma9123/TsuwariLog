import Foundation
import SwiftUI

/// 記録データの状態管理（プロトタイプ用）
@Observable
final class LogStore {
    var entries: [LogEntry] = []

    init() {
        // サンプルデータを生成
        loadSampleData()
    }

    /// 新しい記録を追加
    func addEntry(_ entry: LogEntry) {
        entries.append(entry)
        sortEntries()
    }

    /// 記録を削除
    func deleteEntry(_ entry: LogEntry) {
        entries.removeAll { $0.id == entry.id }
    }

    /// 日付でグループ化した記録を取得
    var entriesByDate: [(date: Date, entries: [LogEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        return grouped
            .map { (date: $0.key, entries: $0.value.sorted { $0.timestamp > $1.timestamp }) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Private

    private func sortEntries() {
        entries.sort { $0.timestamp > $1.timestamp }
    }

    private func loadSampleData() {
        let calendar = Calendar.current
        let now = Date()

        // 今日の記録
        let today = calendar.startOfDay(for: now)

        entries = [
            // 8月30日（今日）の記録
            LogEntry(
                category: .mood,
                timestamp: calendar.date(bySettingHour: 23, minute: 26, second: 0, of: today)!,
                content: .mood(level: .normal)
            ),
            LogEntry(
                category: .symptom,
                timestamp: calendar.date(bySettingHour: 15, minute: 20, second: 0, of: today)!,
                content: .symptom(types: [.nausea, .lossOfAppetite])
            ),
            LogEntry(
                category: .food,
                timestamp: calendar.date(bySettingHour: 12, minute: 40, second: 0, of: today)!,
                content: .food(items: [.karaage, .onigiri])
            ),
            LogEntry(
                category: .hydration,
                timestamp: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: today)!,
                content: .hydration(amount: 1200)
            ),
            LogEntry(
                category: .clinic,
                timestamp: calendar.date(bySettingHour: 9, minute: 15, second: 0, of: today)!,
                content: .clinic(type: .checkup, hospitalName: "金子レディースクリニック", note: nil)
            ),

            // 昨日の記録
            LogEntry(
                category: .mood,
                timestamp: calendar.date(byAdding: .day, value: -1, to: calendar.date(bySettingHour: 22, minute: 10, second: 0, of: today)!)!,
                content: .mood(level: .good)
            ),
        ]

        sortEntries()
    }
}

// MARK: - 日付フォーマット用Extension

extension Date {
    /// 「8月30日」形式
    var monthDayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: self)
    }

    /// 月（数字のみ）
    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    /// 日（数字のみ）
    var day: Int {
        Calendar.current.component(.day, from: self)
    }

    /// 曜日（「日」「月」など）
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter.string(from: self)
    }

    /// 「8月30日（日）」形式
    var fullDateString: String {
        "\(monthDayString)（\(weekdayString)）"
    }

    /// 時刻表示（HH:mm形式）
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}
