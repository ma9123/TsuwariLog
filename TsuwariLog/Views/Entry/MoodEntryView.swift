import SwiftUI
import SwiftData

/// 気分入力画面
struct MoodEntryView: View {
    let modelContext: ModelContext
    let onDismiss: () -> Void

    @State private var selectedMood: MoodLevel?
    @State private var entryDate = Date()

    private var canComplete: Bool {
        selectedMood != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            EntryHeader(
                title: "気分",
                date: $entryDate,
                onDismiss: onDismiss,
                onComplete: saveEntry,
                isCompleteEnabled: canComplete
            )

            ScrollView {
                VStack(alignment: .leading, spacing: Design.paddingL) {
                    // 質問
                    Text("今日の気分は？")
                        .font(.appHeadline())
                        .foregroundStyle(Color.textPrimary)
                        .padding(.horizontal, Design.paddingM)

                    // 5段階の気分選択
                    HStack(spacing: Design.paddingS) {
                        ForEach(MoodLevel.allCases) { mood in
                            MoodButton(
                                mood: mood,
                                isSelected: selectedMood == mood
                            ) {
                                withAnimation(Design.standardAnimation) {
                                    selectedMood = mood
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Design.paddingM)

                    // ヒント
                    HintBox(text: "その日の全体的な調子を\n5段階で選択してください。")
                        .padding(.horizontal, Design.paddingM)

                    Spacer()
                }
                .padding(.top, Design.paddingL)
            }
        }
        .background(Color.cardBackground)
    }

    private func saveEntry() {
        guard let mood = selectedMood else { return }
        let entry = LogEntry(
            category: .mood,
            timestamp: entryDate,
            content: .mood(level: mood)
        )
        modelContext.insert(entry)
        onDismiss()
    }
}

/// 気分選択ボタン
struct MoodButton: View {
    let mood: MoodLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: Design.iconRadius)
                        .fill(isSelected ? Color.moodPastel : Color.appBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: Design.iconRadius)
                                .stroke(isSelected ? Color.selectionBlue : Color.clear, lineWidth: 2)
                        )
                        .frame(width: Design.iconSize, height: Design.iconSize)

                    Image(mood.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Design.iconInnerSize + 4, height: Design.iconInnerSize + 4)
                }

                Text(mood.displayText)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LogEntry.self, configurations: config)
    return MoodEntryView(modelContext: container.mainContext) {}
}
