import SwiftUI
import SwiftData

/// 水分入力画面
struct HydrationEntryView: View {
    let modelContext: ModelContext
    var existingEntry: LogEntry? = nil
    let onDismiss: () -> Void

    @State private var hydrationValue = ""
    @State private var entryDate = Date()

    private var isEditing: Bool { existingEntry != nil }

    private var canComplete: Bool {
        guard let value = Int(hydrationValue), value > 0 else { return false }
        return true
    }

    private var displayValue: String {
        if hydrationValue.isEmpty {
            return "0"
        }
        return hydrationValue
    }

    private var currentAmount: Int {
        Int(hydrationValue) ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            EntryHeader(
                title: "水分",
                date: $entryDate,
                onDismiss: onDismiss,
                onComplete: saveEntry,
                isCompleteEnabled: canComplete
            )

            VStack(spacing: Design.paddingL) {
                // 質問
                Text("水分摂取量を入力してください")
                    .font(.appHeadline())
                    .foregroundStyle(Color.textPrimary)

                // 数値表示
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text(displayValue)
                        .font(.appLargeNumber())
                        .foregroundStyle(Color.textPrimary)
                        .monospacedDigit()

                    Text("ml")
                        .font(.title2)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.horizontal, Design.paddingL)
                .padding(.vertical, Design.paddingM)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: Design.cardRadius)
                        .fill(Color.appBackground)
                )
                .padding(.horizontal, Design.paddingL)

                // クイック入力ボタン
                HStack(spacing: Design.paddingS) {
                    QuickAddButton(label: "+100ml") {
                        hydrationValue = String(currentAmount + 100)
                    }
                    QuickAddButton(label: "+200ml") {
                        hydrationValue = String(currentAmount + 200)
                    }
                    QuickAddButton(label: "+500ml") {
                        hydrationValue = String(currentAmount + 500)
                    }
                }
                .padding(.horizontal, Design.paddingL)

                Spacer()

                // テンキー
                NumericKeypad(value: $hydrationValue, allowDecimal: false)
                    .padding(.horizontal, Design.paddingL)
                    .padding(.bottom, Design.paddingXL)
            }
            .padding(.top, Design.paddingL)
        }
        .background(Color.cardBackground)
        .onAppear {
            if let entry = existingEntry, case .hydration(let amount) = entry.content {
                hydrationValue = String(amount)
                entryDate = entry.timestamp
            }
        }
    }

    private func saveEntry() {
        guard let value = Int(hydrationValue), value > 0 else { return }

        if let entry = existingEntry {
            entry.timestamp = entryDate
            entry.content = .hydration(amount: value)
        } else {
            let entry = LogEntry(
                category: .hydration,
                timestamp: entryDate,
                content: .hydration(amount: value)
            )
            modelContext.insert(entry)
        }
        onDismiss()
    }
}

/// クイック追加ボタン
struct QuickAddButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, Design.paddingM)
                .padding(.vertical, Design.paddingS)
                .background(
                    RoundedRectangle(cornerRadius: Design.keypadButtonRadius)
                        .fill(Color.appBackground)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LogEntry.self, configurations: config)
    return HydrationEntryView(modelContext: container.mainContext) {}
}
