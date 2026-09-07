import SwiftUI

/// 記録カテゴリ（7種類固定）
enum RecordCategory: String, CaseIterable, Identifiable, Codable {
    case mood = "気分"
    case symptom = "症状"
    case food = "食べられた"
    case weight = "体重"
    case hydration = "水分"
    case clinic = "通院・健診"
    case memo = "メモ"

    var id: String { rawValue }

    /// カテゴリ名
    var title: String { rawValue }

    /// カテゴリのパステルカラー（カード背景用・薄め）
    var pastelColor: Color {
        switch self {
        case .mood: return .moodPastel
        case .symptom: return .symptomPastel
        case .food: return .foodPastel
        case .weight: return .weightPastel
        case .hydration: return .hydrationPastel
        case .clinic: return .clinicPastel
        case .memo: return .memoPastel
        }
    }

    /// アイコン背景色（濃いめ）
    var iconBackgroundColor: Color {
        switch self {
        case .mood: return Color(hex: "FFE999")
        case .symptom: return Color(hex: "FFBFCC")
        case .food: return Color(hex: "FFD4B3")
        case .weight: return Color(hex: "B3E5C7")
        case .hydration: return Color(hex: "B3DDFF")
        case .clinic: return Color(hex: "D4C4FF")
        case .memo: return Color(hex: "D4D4D9")
        }
    }

    /// SF Symbolsアイコン名（プロトタイプ用）
    var iconName: String {
        switch self {
        case .mood: return "face.smiling"
        case .symptom: return "heart.text.square"
        case .food: return "fork.knife"
        case .weight: return "scalemass"
        case .hydration: return "drop.fill"
        case .clinic: return "cross.case"
        case .memo: return "square.and.pencil"
        }
    }

    /// カスタム画像名
    var customImageName: String? {
        switch self {
        case .mood: return "MoodGood"  // カテゴリ選択画面では「良い」の顔
        case .symptom: return "MemoKarte"  // カルテアイコン
        case .weight: return "WeightScale"
        case .clinic: return "ClinicHospital"
        default: return nil
        }
    }

    /// カスタム画像を使用するか
    var usesCustomImage: Bool {
        customImageName != nil
    }

    /// アイコンの色
    var iconColor: Color {
        switch self {
        case .mood: return Color(hex: "F5A623")
        case .symptom: return Color(hex: "E85A71")
        case .food: return Color(hex: "C68642")
        case .weight: return Color(hex: "4CAF7A")
        case .hydration: return Color(hex: "4A90D9")
        case .clinic: return Color(hex: "7B68EE")
        case .memo: return Color(hex: "8E8E93")
        }
    }
}
