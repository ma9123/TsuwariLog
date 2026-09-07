import SwiftUI

/// カテゴリアイコン（角丸の正方形背景＋アイコン）
struct CategoryIcon: View {
    let category: RecordCategory
    var size: IconSize = .medium
    var moodLevel: MoodLevel? = nil  // 気分の場合、具体的なレベルを指定

    enum IconSize {
        case small   // タイムライン用
        case medium  // カテゴリ選択用

        var outerSize: CGFloat {
            switch self {
            case .small: return Design.iconSizeSmall
            case .medium: return Design.iconSize
            }
        }

        var innerSize: CGFloat {
            switch self {
            case .small: return Design.iconInnerSizeSmall
            case .medium: return Design.iconInnerSize
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return Design.iconRadiusSmall
            case .medium: return Design.iconRadius
            }
        }
    }

    var body: some View {
        ZStack {
            // 気分以外は背景円を表示
            if category != .mood {
                Circle()
                    .fill(category.iconBackgroundColor)
                    .frame(width: size.outerSize, height: size.outerSize)
            }

            if category == .mood, let mood = moodLevel {
                // 気分: 記録された気分レベルに応じた顔を表示
                Image(mood.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.outerSize, height: size.outerSize)
            } else if let customImage = category.customImageName {
                // カスタム画像を使用
                if category == .mood {
                    // 気分: 背景円と同じサイズ
                    Image(customImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.outerSize, height: size.outerSize)
                } else {
                    // 通院など: 背景円より少し小さく、中央配置
                    Image(customImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.outerSize * 0.75, height: size.outerSize * 0.75)
                }
            } else {
                // SF Symbolsを使用
                Image(systemName: category.iconName)
                    .font(.system(size: size.innerSize, weight: .medium))
                    .foregroundStyle(category.iconColor)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Medium Size")
            .font(.headline)

        HStack(spacing: 16) {
            ForEach(RecordCategory.allCases) { category in
                CategoryIcon(category: category, size: .medium)
            }
        }

        Text("Small Size")
            .font(.headline)

        HStack(spacing: 12) {
            ForEach(RecordCategory.allCases) { category in
                CategoryIcon(category: category, size: .small)
            }
        }
    }
    .padding()
}
