import SwiftUI
import SwiftData

/// 食べられた入力画面
struct FoodEntryView: View {
    let modelContext: ModelContext
    let onDismiss: () -> Void

    @State private var selectedFoods: Set<FoodItem> = []
    @State private var entryDate = Date()

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private var canComplete: Bool {
        !selectedFoods.isEmpty
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
                }
                .padding(.top, Design.paddingL)
            }
        }
        .background(Color.cardBackground)
    }

    private func saveEntry() {
        guard !selectedFoods.isEmpty else { return }
        let entry = LogEntry(
            category: .food,
            timestamp: entryDate,
            content: .food(items: Array(selectedFoods))
        )
        modelContext.insert(entry)
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
