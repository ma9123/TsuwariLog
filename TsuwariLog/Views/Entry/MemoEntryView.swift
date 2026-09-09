import SwiftUI
import SwiftData

/// メモ入力画面
struct MemoEntryView: View {
    let modelContext: ModelContext
    var existingEntry: LogEntry? = nil
    let onDismiss: () -> Void

    @State private var memoText = ""
    @State private var entryDate = Date()

    private let maxLength = 200

    private var isEditing: Bool { existingEntry != nil }

    private var canComplete: Bool {
        !memoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var characterCount: String {
        "\(memoText.count) / \(maxLength)"
    }

    var body: some View {
        VStack(spacing: 0) {
            EntryHeader(
                title: "メモ",
                date: $entryDate,
                onDismiss: onDismiss,
                onComplete: saveEntry,
                isCompleteEnabled: canComplete
            )

            VStack(alignment: .leading, spacing: Design.paddingM) {
                // 質問
                Text("メモを入力してください")
                    .font(.appHeadline())
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, Design.paddingM)

                // テキストエリア
                ZStack(alignment: .bottomTrailing) {
                    TextEditor(text: $memoText)
                        .scrollContentBackground(.hidden)
                        .padding(Design.paddingM)
                        .background(
                            RoundedRectangle(cornerRadius: Design.cardRadius)
                                .fill(Color.appBackground)
                        )
                        .frame(minHeight: 150)
                        .onChange(of: memoText) { _, newValue in
                            if newValue.count > maxLength {
                                memoText = String(newValue.prefix(maxLength))
                            }
                        }

                    // 文字数カウント
                    Text(characterCount)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                        .padding(Design.paddingS)
                }
                .padding(.horizontal, Design.paddingM)

                Spacer()
            }
            .padding(.top, Design.paddingL)
        }
        .background(Color.cardBackground)
        .onAppear {
            if let entry = existingEntry, case .memo(let text) = entry.content {
                memoText = text
                entryDate = entry.timestamp
            }
        }
    }

    private func saveEntry() {
        let trimmedText = memoText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        if let entry = existingEntry {
            entry.timestamp = entryDate
            entry.content = .memo(text: trimmedText)
        } else {
            let entry = LogEntry(
                category: .memo,
                timestamp: entryDate,
                content: .memo(text: trimmedText)
            )
            modelContext.insert(entry)
        }
        UserSettings.shared.updateLastEntryDate()
        onDismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LogEntry.self, configurations: config)
    return MemoEntryView(modelContext: container.mainContext) {}
}
