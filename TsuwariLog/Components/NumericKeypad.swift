import SwiftUI

/// 数値入力用テンキーパッド
struct NumericKeypad: View {
    @Binding var value: String
    var allowDecimal: Bool = true

    private let keys: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]

    var body: some View {
        VStack(spacing: Design.paddingS) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: Design.paddingS) {
                    ForEach(row, id: \.self) { key in
                        KeypadButton(
                            key: key,
                            allowDecimal: allowDecimal,
                            action: { handleKeyPress(key) }
                        )
                    }
                }
            }
        }
    }

    private func handleKeyPress(_ key: String) {
        switch key {
        case "⌫":
            if !value.isEmpty {
                value.removeLast()
            }
        case ".":
            if allowDecimal && !value.contains(".") && !value.isEmpty {
                value.append(".")
            }
        default:
            // 先頭の0を除去（小数点の場合を除く）
            if value == "0" && key != "." {
                value = key
            } else {
                value.append(key)
            }
        }
    }
}

/// テンキーの個別ボタン
struct KeypadButton: View {
    let key: String
    var allowDecimal: Bool = true
    let action: () -> Void

    private var isDisabled: Bool {
        key == "." && !allowDecimal
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: Design.keypadButtonRadius)
                    .fill(key == "⌫" ? Color.clear : Color.appBackground)
                    .frame(height: Design.keypadButtonSize)

                if key == "⌫" {
                    Image(systemName: "delete.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                } else {
                    Text(key)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundStyle(isDisabled ? Color.textTertiary : Color.textPrimary)
                }
            }
        }
        .disabled(isDisabled)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var value = "38.2"

        var body: some View {
            VStack(spacing: 32) {
                Text(value.isEmpty ? "0" : value)
                    .font(.system(size: 48, weight: .light))

                NumericKeypad(value: $value)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
