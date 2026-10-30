import SwiftUI
import SwiftData

/// 症状入力画面
struct SymptomEntryView: View {
    let modelContext: ModelContext
    var existingEntry: LogEntry? = nil
    let onDismiss: () -> Void

    @State private var selectedSymptoms: Set<SymptomType> = []
    @State private var otherText = ""
    @State private var entryDate = Date()

    @FocusState private var isOtherFieldFocused: Bool

    private let maxOtherLength = 50

    private var isEditing: Bool { existingEntry != nil }

    /// 「その他」が選択されているか
    private var isOtherSelected: Bool {
        selectedSymptoms.contains(.other)
    }

    /// enumの定義順に並べた選択中の症状
    private var orderedSymptoms: [SymptomType] {
        SymptomType.allCases.filter { selectedSymptoms.contains($0) }
    }

    private var trimmedOtherText: String {
        otherText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

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
                                        if symptom == .other {
                                            isOtherFieldFocused = false
                                        }
                                    } else {
                                        selectedSymptoms.insert(symptom)
                                        if symptom == .other {
                                            isOtherFieldFocused = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Design.paddingM)

                    // 「その他」の自由記述
                    if isOtherSelected {
                        VStack(alignment: .leading, spacing: Design.paddingS) {
                            Text("その他の症状（任意）")
                                .font(.subheadline)
                                .foregroundStyle(Color.textSecondary)

                            TextField("例：寒気、胸やけ", text: $otherText)
                                .textFieldStyle(.plain)
                                .focused($isOtherFieldFocused)
                                .submitLabel(.done)
                                .padding(Design.paddingM)
                                .background(
                                    RoundedRectangle(cornerRadius: Design.cardRadius)
                                        .fill(Color.appBackground)
                                )
                                .onChange(of: otherText) { _, newValue in
                                    if newValue.count > maxOtherLength {
                                        otherText = String(newValue.prefix(maxOtherLength))
                                    }
                                }
                        }
                        .padding(.horizontal, Design.paddingM)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.top, Design.paddingL)
            }
        }
        .background(Color.cardBackground)
        .onAppear {
            if let entry = existingEntry, case .symptom(let types, let text) = entry.content {
                selectedSymptoms = Set(types)
                otherText = text ?? ""
                entryDate = entry.timestamp
            }
        }
    }

    private func saveEntry() {
        guard !selectedSymptoms.isEmpty else { return }

        let text = isOtherSelected && !trimmedOtherText.isEmpty ? trimmedOtherText : nil
        let content = LogContent.symptom(types: orderedSymptoms, otherText: text)

        if let entry = existingEntry {
            entry.timestamp = entryDate
            entry.content = content
        } else {
            let entry = LogEntry(
                category: .symptom,
                timestamp: entryDate,
                content: content
            )
            modelContext.insert(entry)
        }
        UserSettings.shared.updateLastEntryDate()
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
