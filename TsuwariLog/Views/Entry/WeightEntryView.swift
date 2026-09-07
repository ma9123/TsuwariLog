import SwiftUI
import SwiftData

/// 体重入力画面
struct WeightEntryView: View {
    let modelContext: ModelContext
    let onDismiss: () -> Void

    @State private var weightValue = ""
    @State private var entryDate = Date()

    private var canComplete: Bool {
        guard let value = Double(weightValue), value > 0 else { return false }
        return true
    }

    private var displayValue: String {
        if weightValue.isEmpty {
            return "0"
        }
        return weightValue
    }

    var body: some View {
        VStack(spacing: 0) {
            EntryHeader(
                title: "体重",
                date: $entryDate,
                onDismiss: onDismiss,
                onComplete: saveEntry,
                isCompleteEnabled: canComplete
            )

            VStack(spacing: Design.paddingXL) {
                // 質問
                Text("体重を入力してください")
                    .font(.appHeadline())
                    .foregroundStyle(Color.textPrimary)

                // 数値表示
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text(displayValue)
                        .font(.appLargeNumber())
                        .foregroundStyle(Color.textPrimary)
                        .monospacedDigit()

                    Text("kg")
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

                Spacer()

                // テンキー
                NumericKeypad(value: $weightValue, allowDecimal: true)
                    .padding(.horizontal, Design.paddingL)
                    .padding(.bottom, Design.paddingXL)
            }
            .padding(.top, Design.paddingL)
        }
        .background(Color.cardBackground)
    }

    private func saveEntry() {
        guard let value = Double(weightValue), value > 0 else { return }
        let entry = LogEntry(
            category: .weight,
            timestamp: entryDate,
            content: .weight(value: value)
        )
        modelContext.insert(entry)
        onDismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LogEntry.self, configurations: config)
    return WeightEntryView(modelContext: container.mainContext) {}
}
