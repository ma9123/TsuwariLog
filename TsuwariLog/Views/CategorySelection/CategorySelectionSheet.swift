import SwiftUI

/// カテゴリ選択ボトムシート
struct CategorySelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: RecordCategory?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: Design.paddingL) {
            // ヘッダー
            HStack {
                Text("記録する")
                    .font(.appTitle(22))
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                // 並び替えボタン（見た目のみ、機能なし）
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 14))
                    Text("並び替え")
                        .font(.appSubheadline())
                }
                .foregroundStyle(Color.textTertiary)
            }
            .padding(.horizontal, Design.paddingL)
            .padding(.top, Design.paddingM)

            // カテゴリグリッド
            LazyVGrid(columns: columns, spacing: Design.paddingM) {
                ForEach(RecordCategory.allCases) { category in
                    CategoryGridItem(category: category) {
                        selectedCategory = category
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, Design.paddingL)

            Spacer()
        }
    }
}

/// カテゴリグリッドのアイテム
struct CategoryGridItem: View {
    let category: RecordCategory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Design.paddingS) {
                CategoryIcon(category: category, size: .medium)

                Text(category.title)
                    .font(.appSubheadline())
                    .foregroundStyle(Color.textPrimary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var category: RecordCategory?

        var body: some View {
            CategorySelectionSheet(selectedCategory: $category)
        }
    }

    return PreviewWrapper()
}
