import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import UserNotifications

/// 設定画面
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [LogEntry]
    @StateObject private var settings = UserSettings.shared

    @State private var showDueDatePicker = false
    @State private var tempDueDate = Date()
    @State private var showExportSheet = false
    @State private var showDeleteAlert = false
    @State private var exportedFileURL: URL?

    var body: some View {
        NavigationStack {
            List {
                // 妊娠情報セクション
                pregnancySection

                // リマインダーセクション
                reminderSection

                // データ管理セクション（一旦非表示。dataSectionの実装は残してある）
//                dataSection

                // アプリ情報セクション
                appInfoSection
            }
            .listStyle(.insetGrouped)
            .background(Color.appBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("設定")
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
            .sheet(isPresented: $showDueDatePicker) {
                DueDatePickerSheet(
                    dueDate: $tempDueDate,
                    onSave: {
                        settings.dueDate = tempDueDate
                        showDueDatePicker = false
                    },
                    onCancel: {
                        showDueDatePicker = false
                    }
                )
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showExportSheet) {
                if let url = exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
            .alert("すべてのデータを削除しますか？", isPresented: $showDeleteAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("削除", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("この操作は取り消せません。すべての記録が完全に削除されます。")
            }
        }
    }

    // MARK: - 妊娠情報セクション

    private var pregnancySection: some View {
        Section {
            // 出産予定日
            Button(action: {
                tempDueDate = settings.dueDate ?? estimatedDueDate()
                showDueDatePicker = true
            }) {
                HStack {
                    Label("出産予定日", systemImage: "calendar")
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    if let dueDate = settings.dueDate {
                        Text(dueDate.yearMonthDayString)
                            .foregroundStyle(Color.textSecondary)
                    } else {
                        Text("未設定")
                            .foregroundStyle(Color.textTertiary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.textTertiary)
                }
            }

            // 現在の妊娠週数（出産予定日が設定されている場合のみ表示）
            if let weekString = settings.pregnancyWeekString {
                HStack {
                    Label("現在の週数", systemImage: "figure.stand")
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    Text(weekString)
                        .font(.appHeadline())
                        .foregroundStyle(Color.primaryBlue)
                }

                if let daysString = settings.daysUntilDueString {
                    HStack {
                        Label("予定日まで", systemImage: "hourglass")
                            .foregroundStyle(Color.textPrimary)
                        Spacer()
                        Text(daysString)
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
        } header: {
            Text("妊娠情報")
        }
    }

    // MARK: - リマインダーセクション

    private var reminderSection: some View {
        Section {
            Toggle(isOn: $settings.reminderEnabled) {
                Label("リマインダー", systemImage: "bell")
                    .foregroundStyle(Color.textPrimary)
            }
            .tint(Color.primaryBlue)
            .onChange(of: settings.reminderEnabled) { _, newValue in
                if newValue {
                    settings.requestNotificationPermission { granted in
                        if granted {
                            settings.scheduleReminder()
                        } else {
                            settings.reminderEnabled = false
                        }
                    }
                } else {
                    settings.cancelReminder()
                }
            }

            if settings.reminderEnabled {
                DatePicker(
                    selection: Binding(
                        get: { settings.reminderTime },
                        set: { settings.reminderTime = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                ) {
                    Label("通知時刻", systemImage: "clock")
                        .foregroundStyle(Color.textPrimary)
                }
                .onChange(of: settings.reminderTime) { _, _ in
                    settings.scheduleReminder()
                }
            }
        } header: {
            Text("リマインダー")
        } footer: {
            if settings.reminderEnabled {
                Text("毎日指定した時刻に記録を促す通知が届きます")
            }
        }
        .onAppear {
            // 画面表示時に通知許可状態を確認
            if settings.reminderEnabled {
                settings.checkNotificationPermission { authorized in
                    if !authorized {
                        settings.reminderEnabled = false
                    }
                }
            }
        }
    }

    // MARK: - データ管理セクション

    private var dataSection: some View {
        Section {
            // データエクスポート
            Button(action: exportData) {
                HStack {
                    Label("データをエクスポート", systemImage: "square.and.arrow.up")
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    Text("\(entries.count)件")
                        .foregroundStyle(Color.textSecondary)
                }
            }

            // 全データ削除
            Button(action: { showDeleteAlert = true }) {
                Label("すべてのデータを削除", systemImage: "trash")
                    .foregroundStyle(Color.red)
            }
        } header: {
            Text("データ管理")
        }
    }

    // MARK: - アプリ情報セクション

    private var appInfoSection: some View {
        Section {
            HStack {
                Label("バージョン", systemImage: "info.circle")
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text(appVersion)
                    .foregroundStyle(Color.textSecondary)
            }

            // TODO: リリース時に実際のURLを設定
            /*
            Link(destination: URL(string: "https://example.com/privacy")!) {
                HStack {
                    Label("プライバシーポリシー", systemImage: "hand.raised")
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textTertiary)
                }
            }

            Link(destination: URL(string: "https://example.com/terms")!) {
                HStack {
                    Label("利用規約", systemImage: "doc.text")
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textTertiary)
                }
            }
            */
        } header: {
            Text("アプリ情報")
        }
    }

    // MARK: - ヘルパー

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    /// 出産予定日の初期推定値（現在から約6ヶ月後）
    private func estimatedDueDate() -> Date {
        Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    }

    // MARK: - データエクスポート

    private func exportData() {
        let csvContent = generateCSV()

        let fileName = "tsuwari_log_\(Date().exportFileName).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            exportedFileURL = tempURL
            showExportSheet = true
        } catch {
            print("Export failed: \(error)")
        }
    }

    private func generateCSV() -> String {
        var csv = "日時,カテゴリ,内容\n"

        let sortedEntries = entries.sorted { $0.timestamp < $1.timestamp }

        for entry in sortedEntries {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            let dateString = dateFormatter.string(from: entry.timestamp)

            let category = entry.category.title
            let content = entry.summaryText.replacingOccurrences(of: ",", with: "、")

            csv += "\"\(dateString)\",\"\(category)\",\"\(content)\"\n"
        }

        return csv
    }

    // MARK: - データ削除

    private func deleteAllData() {
        for entry in entries {
            modelContext.delete(entry)
        }
    }
}

// MARK: - 出産予定日選択シート

struct DueDatePickerSheet: View {
    @Binding var dueDate: Date
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "",
                    selection: $dueDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .padding(.horizontal, Design.paddingL)
                .padding(.top, Design.paddingM)
            }
            .background(Color.cardBackground)
            .navigationTitle("出産予定日")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル", action: onCancel)
                        .foregroundStyle(Color.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存", action: onSave)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primaryBlue)
                }
            }
        }
    }
}

// MARK: - 共有シート

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Date Extension for Export

extension Date {
    var exportFileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: self)
    }

    var yearMonthDayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: self)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LogEntry.self, configurations: config)
    return SettingsView()
        .modelContainer(container)
}
