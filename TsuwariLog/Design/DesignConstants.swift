import SwiftUI

/// デザイン定数
enum Design {

    // MARK: - カードスタイル

    /// カードの角丸
    static let cardRadius: CGFloat = 24

    /// カード内のパディング
    static let cardPadding: CGFloat = 16

    /// カード間のスペース
    static let cardSpacing: CGFloat = 16

    // MARK: - カテゴリアイコン

    /// アイコン外側のサイズ（背景込み）
    static let iconSize: CGFloat = 56

    /// アイコン内側のサイズ（シンボルやイラスト）
    static let iconInnerSize: CGFloat = 28

    /// アイコンの角丸
    static let iconRadius: CGFloat = 16

    /// タイムライン用の小さいアイコンサイズ
    static let iconSizeSmall: CGFloat = 56
    static let iconInnerSizeSmall: CGFloat = 28
    static let iconRadiusSmall: CGFloat = 12

    // MARK: - フローティングボタン

    /// FABのサイズ
    static let fabSize: CGFloat = 56

    /// FAB内のアイコンサイズ
    static let fabIconSize: CGFloat = 24

    // MARK: - スペーシング

    /// 小さいパディング
    static let paddingXS: CGFloat = 4

    /// 小さいパディング
    static let paddingS: CGFloat = 8

    /// 標準パディング
    static let paddingM: CGFloat = 16

    /// 大きいパディング
    static let paddingL: CGFloat = 24

    /// 特大パディング
    static let paddingXL: CGFloat = 32

    /// セクション間のスペース
    static let sectionSpacing: CGFloat = 24

    // MARK: - タイムライン

    /// 縦線の幅
    static let timelineLineWidth: CGFloat = 2

    /// 縦線の左マージン
    static let timelineLineLeading: CGFloat = 74

    // MARK: - 入力画面

    /// テンキーボタンのサイズ
    static let keypadButtonSize: CGFloat = 64

    /// テンキーボタンの角丸
    static let keypadButtonRadius: CGFloat = 12

    /// 大きな数値表示のフォントサイズ
    static let largeNumberFontSize: CGFloat = 48

    // MARK: - アニメーション

    /// 標準のアニメーション
    static let standardAnimation = Animation.easeInOut(duration: 0.2)

    /// スプリングアニメーション
    static let springAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)
}
