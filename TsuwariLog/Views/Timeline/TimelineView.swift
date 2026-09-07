import SwiftUI
import SwiftData

/// メイン画面：タイムライン
struct TimelineView: View {
    @Query(sort: \LogEntry.timestamp, order: .reverse) private var entries: [LogEntry]
    @Environment(\.modelContext) private var modelContext
    @State private var showCategorySheet = false
    @State private var selectedCategory: RecordCategory?

    /// 日付でグループ化した記録を取得
    private var entriesByDate: [(date: Date, entries: [LogEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        return grouped
            .map { (date: $0.key, entries: $0.value.sorted { $0.timestamp > $1.timestamp }) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ヘッダー
                TimelineHeader()

                // タイムラインコンテンツ
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(entriesByDate, id: \.date) { dateGroup in
                            Section {
                                TimelineDateSection(entries: dateGroup.entries)
                            } header: {
                                DateSectionHeader(date: dateGroup.date)
                            }
                        }
                    }
                    .padding(.bottom, 100) // FAB用の余白
                }
            }

            // フローティング追加ボタン
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingAddButton {
                        showCategorySheet = true
                    }
                    .padding(.trailing, Design.paddingL)
                    .padding(.bottom, Design.paddingL)
                }
            }
        }
        .sheet(isPresented: $showCategorySheet) {
            CategorySelectionSheet(selectedCategory: $selectedCategory)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $selectedCategory) { category in
            EntryRouter(category: category, modelContext: modelContext) {
                selectedCategory = nil
            }
        }
    }
}

/// タイムラインヘッダー
struct TimelineHeader: View {
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.textPrimary)
            }

            Spacer()

            Text("つわり日記")
                .font(.appTitle(18))
                .foregroundStyle(Color.textPrimary)

            Spacer()

            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.textPrimary)
                }

                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
        .padding(.horizontal, Design.paddingM)
        .padding(.vertical, Design.paddingS)
        .background(Color.cardBackground)
    }
}

/// 日付セクションヘッダー
struct DateSectionHeader: View {
    let date: Date

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 2) {
                Text("\(date.month)")
                    .font(.appTitle(20))
                    .foregroundStyle(Color.textPrimary)
                Text("月")
                    .font(.appTitle(15))
                    .foregroundStyle(Color.textPrimary)
                Text("\(date.day)")
                    .font(.appTitle(20))
                    .foregroundStyle(Color.textPrimary)
                Text("日")
                    .font(.appTitle(15))
                    .foregroundStyle(Color.textPrimary)
            }

            Text(date.weekdayString)
                .font(.appSubheadline())
                .foregroundStyle(Color.textSecondary)
                .frame(width: 22, height: 22)
                .background(
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.1))
                )

            Spacer()
        }
        .padding(.horizontal, Design.paddingM)
        .padding(.vertical, Design.paddingS)
        .background(Color.appBackground)
    }
}

/// 日付セクション内のエントリーリスト
struct TimelineDateSection: View {
    let entries: [LogEntry]

    var body: some View {
        ZStack(alignment: .leading) {
            // 縦線（カードの下に描画）
            Rectangle()
                .fill(Color.timelineLine)
                .frame(width: Design.timelineLineWidth)
                .padding(.leading, Design.timelineLineLeading)

            // カードリスト
            VStack(spacing: Design.cardSpacing) {
                ForEach(entries) { entry in
                    TimelineCard(entry: entry)
                }
            }
            .padding(.horizontal, Design.paddingXL)
        }
    }
}

/// タイムラインカード（アイコン内蔵）
struct TimelineCard: View {
    let entry: LogEntry

    // 気分の場合、具体的なレベルを取得
    private var moodLevel: MoodLevel? {
        if case .mood(let level) = entry.content {
            return level
        }
        return nil
    }

    var body: some View {
        HStack(spacing: Design.paddingM) {
            // カテゴリアイコン
            CategoryIcon(
                category: entry.category,
                size: .small,
                moodLevel: moodLevel
            )

            // コンテンツ
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.timeString)
                    .font(.appCaption())
                    .foregroundStyle(Color.textSecondary)

                // 通院・健診の場合は病院名をグレーで表示
                if case .clinic(let type, let hospitalName, _) = entry.content {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(type.rawValue)
                            .font(.appHeadline(16))
                            .foregroundStyle(Color.textPrimary)

                        if let name = hospitalName, !name.isEmpty {
                            Text(name)
                                .font(.appCaption())
                                .foregroundStyle(Color.textSecondary)
                                .lineLimit(1)
                        }
                    }
                } else if case .memo = entry.content {
                    // メモは普通の太さで表示
                    Text(entry.summaryText)
                        .font(.appBody(16))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(2)
                } else {
                    Text(entry.summaryText)
                        .font(.appHeadline(16))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(2)
                }
            }

            Spacer()

            // メニューボタン
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(.horizontal, Design.cardPadding)
        .padding(.vertical, Design.cardPadding - 6)
        .background(
            ZStack {
                // 白背景（縦線を隠す）
                RoundedRectangle(cornerRadius: Design.cardRadius)
                    .fill(Color.cardBackground)

                // カテゴリ別のパステルカラーオーバーレイ（気分以外）
                if entry.category != .mood {
                    RoundedRectangle(cornerRadius: Design.cardRadius)
                        .fill(entry.category.pastelColor.opacity(0.2))
                }
            }
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

/// 入力画面ルーター
struct EntryRouter: View {
    let category: RecordCategory
    let modelContext: ModelContext
    let onDismiss: () -> Void

    var body: some View {
        switch category {
        case .mood:
            MoodEntryView(modelContext: modelContext, onDismiss: onDismiss)
        case .symptom:
            SymptomEntryView(modelContext: modelContext, onDismiss: onDismiss)
        case .food:
            FoodEntryView(modelContext: modelContext, onDismiss: onDismiss)
        case .weight:
            WeightEntryView(modelContext: modelContext, onDismiss: onDismiss)
        case .hydration:
            HydrationEntryView(modelContext: modelContext, onDismiss: onDismiss)
        case .clinic:
            ClinicEntryView(modelContext: modelContext, onDismiss: onDismiss)
        case .memo:
            MemoEntryView(modelContext: modelContext, onDismiss: onDismiss)
        }
    }
}

#Preview {
    TimelineView()
}
