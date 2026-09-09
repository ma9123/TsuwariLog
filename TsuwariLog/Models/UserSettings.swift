import Foundation
import SwiftUI
import UserNotifications

/// ユーザー設定を管理するクラス
class UserSettings: ObservableObject {
    static let shared = UserSettings()

    // MARK: - 妊娠情報

    /// 出産予定日
    @AppStorage("dueDate") var dueDateTimestamp: Double = 0

    var dueDate: Date? {
        get {
            dueDateTimestamp > 0 ? Date(timeIntervalSince1970: dueDateTimestamp) : nil
        }
        set {
            dueDateTimestamp = newValue?.timeIntervalSince1970 ?? 0
            objectWillChange.send()
        }
    }

    /// 現在の妊娠週数を計算
    var pregnancyWeek: (weeks: Int, days: Int)? {
        guard let dueDate = dueDate else { return nil }

        let calendar = Calendar.current
        // 出産予定日は妊娠40週0日
        // 最終月経開始日 = 出産予定日 - 280日
        let lastMenstrualDate = calendar.date(byAdding: .day, value: -280, to: dueDate)!
        let today = calendar.startOfDay(for: Date())
        let lmpStart = calendar.startOfDay(for: lastMenstrualDate)

        let daysSinceLMP = calendar.dateComponents([.day], from: lmpStart, to: today).day ?? 0

        if daysSinceLMP < 0 {
            return nil
        }

        let weeks = daysSinceLMP / 7
        let days = daysSinceLMP % 7

        return (weeks: weeks, days: days)
    }

    /// 妊娠月数（4週で1ヶ月）
    var pregnancyMonth: Int? {
        guard let week = pregnancyWeek else { return nil }
        return (week.weeks / 4) + 1
    }

    /// 妊娠週数の表示文字列
    var pregnancyWeekString: String? {
        guard let week = pregnancyWeek else { return nil }
        if let month = pregnancyMonth {
            return "\(week.weeks)週\(week.days)日（\(month)ヶ月）"
        }
        return "\(week.weeks)週\(week.days)日"
    }

    // MARK: - リマインダー設定

    /// リマインダーが有効か
    @AppStorage("reminderEnabled") var reminderEnabled: Bool = false

    /// リマインダー時刻（時）
    @AppStorage("reminderHour") var reminderHour: Int = 20

    /// リマインダー時刻（分）
    @AppStorage("reminderMinute") var reminderMinute: Int = 0

    /// 最終記録日時
    @AppStorage("lastEntryDate") var lastEntryTimestamp: Double = 0

    /// 最終記録日を更新
    func updateLastEntryDate() {
        lastEntryTimestamp = Date().timeIntervalSince1970
        // 通知メッセージを更新
        if reminderEnabled {
            scheduleReminder()
        }
    }

    /// 3日以内に記録があるか
    var hasRecentEntry: Bool {
        guard lastEntryTimestamp > 0 else { return false }
        let lastDate = Date(timeIntervalSince1970: lastEntryTimestamp)
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        return lastDate >= threeDaysAgo
    }

    /// リマインダー時刻のDate表現
    var reminderTime: Date {
        get {
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderHour = components.hour ?? 20
            reminderMinute = components.minute ?? 0
            objectWillChange.send()
        }
    }

    // MARK: - 初期化

    private init() {}
}

// MARK: - 妊娠週数の計算ヘルパー

extension UserSettings {
    /// 出産予定日までの残り日数
    var daysUntilDue: Int? {
        guard let dueDate = dueDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let due = calendar.startOfDay(for: dueDate)
        return calendar.dateComponents([.day], from: today, to: due).day
    }

    /// 出産予定日までの残り表示
    var daysUntilDueString: String? {
        guard let days = daysUntilDue else { return nil }
        if days > 0 {
            return "あと\(days)日"
        } else if days == 0 {
            return "今日が予定日"
        } else {
            return "予定日を\(-days)日経過"
        }
    }
}

// MARK: - 通知関連

extension UserSettings {
    /// アプリ起動時にリマインダーを再スケジュール
    func setupRemindersOnLaunch() {
        checkNotificationPermission { [weak self] authorized in
            guard let self = self else { return }
            if authorized && self.reminderEnabled {
                self.scheduleReminder()
            } else if !authorized {
                // 通知が許可されていない場合はOFFにする
                DispatchQueue.main.async {
                    self.reminderEnabled = false
                }
            }
        }
    }

    /// 通知許可状態を確認
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    /// 通知許可をリクエスト
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    /// リマインダーをスケジュール
    func scheduleReminder() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        guard reminderEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "つわり日記"

        // 3日以内に記録があるかで文言を変える
        if hasRecentEntry {
            content.body = "今日もおつかれさま。体調を記録しておこう🌿"
        } else {
            content.body = "今日もおつかれさま。気分はどうですか？🌿"
        }

        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)

        center.add(request)
    }

    /// リマインダーをキャンセル
    func cancelReminder() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
