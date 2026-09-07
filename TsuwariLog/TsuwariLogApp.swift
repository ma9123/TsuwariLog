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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: LogEntry.self)
    }
}
