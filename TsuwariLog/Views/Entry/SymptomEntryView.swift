import SwiftUI
import SwiftData

/// 症状入力画面
struct SymptomEntryView: View {
    let modelContext: ModelContext
    let onDismiss: () -> Void

    @State private var selectedSymptoms: Set<SymptomType> = []
    @State private var entryDate = Date()

    private var canComplete: Bool {
        !selectedSymptoms.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            EntryHeader(
                title: "症状",
                date: $entryDate,
                onDismiss: onDismiss,
                onComplete: saveEntry,
                isCompleteEnabled: canComplete
            )

            ScrollView {
                VStack(alignment: .leading, spacing: Design.paddingM) {
                    // 質問
                    Text("どのような症状がありましたか？")
                        .font(.appHeadline())
                        .foregroundStyle(Color.textPrimary)
                        .padding(.horizontal, Design.paddingM)

                    // 症状カードリスト
                    VStack(spacing: 6) {
                        ForEach(SymptomType.allCases) { symptom in
                            SymptomCard(
                                symptom: symptom,
                                isSelected: selectedSymptoms.contains(symptom)
                            ) {
                                withAnimation(Design.standardAnimation) {
                                    if selectedSymptoms.contains(symptom) {
                                        selectedSymptoms.remove(symptom)
                                    } else {
                                        selectedSymptoms.insert(symptom)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Design.paddingM)
                }
                .padding(.top, Design.paddingL)
            }
        }
        .background(Color.cardBackground)
    }

    private func saveEntry() {
        guard !selectedSymptoms.isEmpty else { return }
        let entry = LogEntry(
            category: .symptom,
            timestamp: entryDate,
            content: .symptom(types: Array(selectedSymptoms))
        )
        modelContext.insert(entry)
        onDismiss()
    }
}

/// 症状カード
struct SymptomCard: View {
    let symptom: SymptomType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Design.paddingS) {
                // アイコン
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(symptom.color.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: symptom.iconName)
                        .font(.system(size: 14))
                        .foregroundStyle(symptom.color)
                }

                // テキスト
                Text(symptom.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                // 選択マーク
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.selectionOrange)
                }
            }
            .padding(.horizontal, Design.paddingM)
            .padding(.vertical, Design.paddingS)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.symptomPastel : Color.appBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.selectionOrange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LogEntry.self, configurations: config)
    return SymptomEntryView(modelContext: container.mainContext) {}
}
