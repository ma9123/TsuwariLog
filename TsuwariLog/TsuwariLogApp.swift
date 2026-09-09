//
//  TsuwariLogApp.swift
//  TsuwariLog
//
//  Created by 伊藤真依 on 2026/09/01.
//

import SwiftUI
import SwiftData

@main
struct TsuwariLogApp: App {
    init() {
        // アプリ起動時にリマインダーを再スケジュール
        UserSettings.shared.setupRemindersOnLaunch()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: LogEntry.self)
    }
}
