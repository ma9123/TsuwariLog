import SwiftUI

/// アプリ全体で使用するフォントスタイル
extension Font {
    /// タイトル用（大きめ・丸み）
    static func appTitle(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    /// 見出し用
    static func appHeadline(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    /// 本文用
    static func appBody(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    /// サブテキスト用
    static func appSubheadline(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    /// キャプション用
    static func appCaption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    /// 大きな数値用
    static func appLargeNumber(_ size: CGFloat = 48) -> Font {
        .system(size: size, weight: .light, design: .rounded)
    }
}
