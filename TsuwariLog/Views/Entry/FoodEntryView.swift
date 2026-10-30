import SwiftUI
import SwiftData

/// 食べられた入力画面
struct FoodEntryView: View {
    let modelContext: ModelContext
    var existingEntry: LogEntry? = nil
    let onDismiss: () -> Void

    @State private var selectedFoods: Set<FoodItem> = []
    @State private var otherText = ""
    @State private var entryDate = Date()

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private let maxOtherLength = 50

    private var isEditing: Bool { existingEntry != nil }

    /// enumの定義順に並べた選択中の食べ物
    private var orderedFoods: [FoodItem] {
        FoodItem.allCases.filter { selectedFoods.contains($0) }
    }

    private var trimmedOtherText: String {
        otherText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// グリッド選択か自由記述のどちらかがあれば保存できる
    private var canComplete: Bool {
        !selectedFoods.isEmpty || !trimmedOtherText.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            EntryHeader(
                title: "食べられた",
                date: $entryDate,
                onDismiss: onDismiss,
                onComplete: saveEntry,
                isCompleteEnabled: canComplete
            )

            ScrollView {
                VStack(alignment: .leading, spacing: Design.paddingM) {
                    // 質問
                    VStack(alignment: .leading, spacing: 4) {
                        Text("今日、食べられたものは？")
                            .font(.appHeadline())
                            .foregroundStyle(Color.textPrimary)

                        Text("複数選択できます")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(.horizontal, Design.paddingM)

                    // 食べ物グリッド
                    LazyVGrid(columns: columns, spacing: Design.paddingM) {
                        ForEach(FoodItem.allCases) { food in
                            FoodGridItem(
                                food: food,
                                isSelected: selectedFoods.contains(food)
                            ) {
                                withAnimation(Design.standardAnimation) {
                                    if selectedFoods.contains(food) {
                                        selectedFoods.remove(food)
                                    } else {
                                        selectedFoods.insert(food)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Design.paddingM)

                    // 自由記述（リストにないもの）
                    VStack(alignment: .leading, spacing: Design.paddingS) {
                        Text("自由記述（任意）")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)

                        TextField("リストにないものを書けます", text: $otherText)
                            .textFieldStyle(.plain)
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
                    .padding(.top, Design.paddingS)
                }
                .padding(.top, Design.paddingL)
            }
        }
        .background(Color.cardBackground)
        .onAppear {
            if let entry = existingEntry, case .food(let items, let text) = entry.content {
                selectedFoods = Set(items)
                otherText = text ?? ""
                entryDate = entry.timestamp
            }
        }
    }

    private func saveEntry() {
        guard canComplete else { return }

        let content = LogContent.food(
            items: orderedFoods,
            otherText: trimmedOtherText.isEmpty ? nil : trimmedOtherText
        )

        if let entry = existingEntry {
            entry.timestamp = entryDate
            entry.content = content
        } else {
            let entry = LogEntry(
                category: .food,
                timestamp: entryDate,
                content: content
            )
            modelContext.insert(entry)
        }
        UserSettings.shared.updateLastEntryDate()
        onDismiss()
    }
}

/// 食べ物グリッドアイテム
struct FoodGridItem: View {
    let food: FoodItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: Design.cardRadius)
                        .fill(isSelected ? Color.foodPastel : Color.appBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: Design.cardRadius)
                                .stroke(isSelected ? Color.selectionOrange : Color.clear, lineWidth: 2)
                        )
                        .frame(height: 72)

                    // 選択マーク
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.selectionOrange)
                            .padding(6)
                    }

                    // アイコン（中央）- カスタム画像を使用
                    Image(food.customImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Text(food.rawValue)
                    .font(.caption)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LogEntry.self, configurations: config)
    return FoodEntryView(modelContext: container.mainContext) {}
}
