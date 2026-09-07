import SwiftUI

extension Color {

    // MARK: - Hex初期化
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - 背景色

    /// アプリ全体の背景（薄いグレー）
    static let appBackground = Color(hex: "F5F5F7")

    /// カードの背景（白）
    static let cardBackground = Color.white

    // MARK: - カテゴリ別パステルカラー（カード背景用）

    /// 気分（黄色系パステル）
    static let moodPastel = Color(hex: "FFF4CC")

    /// 症状（ピンク系パステル）
    static let symptomPastel = Color(hex: "FFDDE5")

    /// 食べられた（ベージュ・オレンジ系パステル）
    static let foodPastel = Color(hex: "FFE8D4")

    /// 体重（緑系パステル）
    static let weightPastel = Color(hex: "D4F0E0")

    /// 水分（水色系パステル）
    static let hydrationPastel = Color(hex: "D4ECFF")

    /// 通院・健診（薄紫系パステル）
    static let clinicPastel = Color(hex: "E8DFFF")

    /// メモ（グレー系パステル）
    static let memoPastel = Color(hex: "E8E8EC")

    // MARK: - アクセントカラー

    /// プライマリブルー（完了ボタンなど）
    static let primaryBlue = Color(hex: "007AFF")

    /// フローティングボタンの黒
    static let floatingButtonColor = Color(hex: "1C1C1E")

    /// 選択状態のオレンジ（食べられた等）
    static let selectionOrange = Color(hex: "FF9500")

    /// 選択状態のブルー（通院・健診等）
    static let selectionBlue = Color(hex: "007AFF")

    // MARK: - テキストカラー

    /// メインテキスト（黒）
    static let textPrimary = Color(hex: "1C1C1E")

    /// サブテキスト（グレー）
    static let textSecondary = Color(hex: "8E8E93")

    /// 薄いテキスト・ボーダー
    static let textTertiary = Color(hex: "C7C7CC")

    /// プレースホルダー
    static let textPlaceholder = Color(hex: "AEAEB2")

    // MARK: - タイムライン

    /// タイムラインの縦線
    static let timelineLine = Color(hex: "D1D1D6")
}
