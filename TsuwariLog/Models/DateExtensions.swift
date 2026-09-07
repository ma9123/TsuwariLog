import Foundation

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
