import SwiftUI

/// 使い方のヒントを表示するボックス
struct HintBox: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Design.paddingS) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: "F5A623"))

            VStack(alignment: .leading, spacing: 4) {
                Text("使い方のヒント")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.textPrimary)

                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Design.paddingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Design.cardRadius)
                .fill(Color(hex: "FFFBF0"))
        )
    }
}

#Preview {
    HintBox(text: "その日の全体的な調子を\n5段階で選択してください。")
        .padding()
}
