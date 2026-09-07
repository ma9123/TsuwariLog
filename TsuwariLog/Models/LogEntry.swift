import Foundation
import SwiftUI
import SwiftData

/// 記録エントリー
@Model
final class LogEntry {
    var id: UUID
    var category: RecordCategory
    var timestamp: Date
    var contentData: Data  // LogContentをCodableでシリアライズして保存

    init(
        id: UUID = UUID(),
        category: RecordCategory,
        timestamp: Date = Date(),
        content: LogContent
    ) {
        self.id = id
        self.category = category
        self.timestamp = timestamp
        // LogContentをDataに変換
        self.contentData = (try? JSONEncoder().encode(content)) ?? Data()
    }

    /// LogContentを取得する計算プロパティ
    var content: LogContent {
        get {
            (try? JSONDecoder().decode(LogContent.self, from: contentData)) ?? .memo(text: "")
        }
        set {
            self.contentData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
}

/// カテゴリ別の記録内容
enum LogContent: Codable {
    /// 気分（5段階）
    case mood(level: MoodLevel)

    /// 症状（複数選択可）
    case symptom(types: [SymptomType])

    /// 食べられた（複数選択可）
    case food(items: [FoodItem])

    /// 体重
    case weight(value: Double)

    /// 水分
    case hydration(amount: Int)

    /// 通院・健診
    case clinic(type: ClinicType, hospitalName: String?, note: String?)

    /// メモ
    case memo(text: String)

    // Codable実装
    private enum CodingKeys: String, CodingKey {
        case type, level, types, items, value, amount, clinicType, hospitalName, note, text
    }

    private enum ContentType: String, Codable {
        case mood, symptom, food, weight, hydration, clinic, memo
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ContentType.self, forKey: .type)

        switch type {
        case .mood:
            let level = try container.decode(MoodLevel.self, forKey: .level)
            self = .mood(level: level)
        case .symptom:
            let types = try container.decode([SymptomType].self, forKey: .types)
            self = .symptom(types: types)
        case .food:
            let items = try container.decode([FoodItem].self, forKey: .items)
            self = .food(items: items)
        case .weight:
            let value = try container.decode(Double.self, forKey: .value)
            self = .weight(value: value)
        case .hydration:
            let amount = try container.decode(Int.self, forKey: .amount)
            self = .hydration(amount: amount)
        case .clinic:
            let clinicType = try container.decode(ClinicType.self, forKey: .clinicType)
            let hospitalName = try container.decodeIfPresent(String.self, forKey: .hospitalName)
            let note = try container.decodeIfPresent(String.self, forKey: .note)
            self = .clinic(type: clinicType, hospitalName: hospitalName, note: note)
        case .memo:
            let text = try container.decode(String.self, forKey: .text)
            self = .memo(text: text)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .mood(let level):
            try container.encode(ContentType.mood, forKey: .type)
            try container.encode(level, forKey: .level)
        case .symptom(let types):
            try container.encode(ContentType.symptom, forKey: .type)
            try container.encode(types, forKey: .types)
        case .food(let items):
            try container.encode(ContentType.food, forKey: .type)
            try container.encode(items, forKey: .items)
        case .weight(let value):
            try container.encode(ContentType.weight, forKey: .type)
            try container.encode(value, forKey: .value)
        case .hydration(let amount):
            try container.encode(ContentType.hydration, forKey: .type)
            try container.encode(amount, forKey: .amount)
        case .clinic(let type, let hospitalName, let note):
            try container.encode(ContentType.clinic, forKey: .type)
            try container.encode(type, forKey: .clinicType)
            try container.encodeIfPresent(hospitalName, forKey: .hospitalName)
            try container.encodeIfPresent(note, forKey: .note)
        case .memo(let text):
            try container.encode(ContentType.memo, forKey: .type)
            try container.encode(text, forKey: .text)
        }
    }
}

// MARK: - 気分レベル

enum MoodLevel: String, CaseIterable, Identifiable, Codable {
    case veryGood = "とても良い"
    case good = "良い"
    case normal = "ふつう"
    case bad = "つらい"
    case veryBad = "とてもつらい"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .veryGood: return "😊"
        case .good: return "🙂"
        case .normal: return "😐"
        case .bad: return "😔"
        case .veryBad: return "😢"
        }
    }

    var imageName: String {
        switch self {
        case .veryGood: return "MoodVeryGood"
        case .good: return "MoodGood"
        case .normal: return "MoodNormal"
        case .bad: return "MoodBad"
        case .veryBad: return "MoodVeryBad"
        }
    }

    var displayText: String { rawValue }
}

// MARK: - 症状タイプ

enum SymptomType: String, CaseIterable, Identifiable, Codable {
    case nausea = "吐き気"
    case vomiting = "嘔吐"
    case lossOfAppetite = "食欲不振"
    case drowsiness = "眠気"
    case headache = "頭痛"
    case dizziness = "めまい"
    case backPain = "腰痛"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .nausea: return "face.dashed"
        case .vomiting: return "arrow.up.heart"
        case .lossOfAppetite: return "fork.knife.circle"
        case .drowsiness: return "moon.zzz"
        case .headache: return "brain.head.profile"
        case .dizziness: return "tornado"
        case .backPain: return "figure.walk"
        }
    }

    var color: Color {
        switch self {
        case .nausea: return .orange
        case .vomiting: return .purple
        case .lossOfAppetite: return .red
        case .drowsiness: return .blue
        case .headache: return .pink
        case .dizziness: return .green
        case .backPain: return .yellow
        }
    }
}

// MARK: - 食べ物アイテム

enum FoodItem: String, CaseIterable, Identifiable, Codable {
    case onigiri = "おにぎり"
    case udon = "うどん"
    case bread = "パン"
    case rice = "ごはん"
    case karaage = "唐揚げ"
    case meat = "肉・揚げ物"
    case egg = "卵"
    case dairy = "乳製品"
    case banana = "バナナ"
    case fruit = "果物"
    case jelly = "ゼリー"
    case other = "その他"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .onigiri: return "triangle.fill"
        case .udon: return "oval.fill"
        case .bread: return "oval.portrait.fill"
        case .rice: return "circle.fill"
        case .karaage: return "square.fill"
        case .meat: return "rectangle.fill"
        case .egg: return "oval.fill"
        case .dairy: return "cup.and.saucer.fill"
        case .banana: return "leaf.fill"
        case .fruit: return "apple.logo"
        case .jelly: return "drop.fill"
        case .other: return "ellipsis"
        }
    }

    var customImageName: String {
        switch self {
        case .onigiri: return "FoodOnigiri"
        case .udon: return "FoodUdon"
        case .bread: return "FoodBread"
        case .rice: return "FoodRice"
        case .karaage: return "FoodKaraage"
        case .meat: return "FoodMeat"
        case .egg: return "FoodEgg"
        case .dairy: return "FoodDairy"
        case .banana: return "FoodBanana"
        case .fruit: return "FoodFruit"
        case .jelly: return "FoodJelly"
        case .other: return "FoodOther"
        }
    }
}

// MARK: - 通院タイプ

enum ClinicType: String, CaseIterable, Identifiable, Codable {
    case checkup = "健診"
    case visit = "通院"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .checkup: return "stethoscope"
        case .visit: return "cross.case"
        }
    }

    var customImageName: String {
        switch self {
        case .checkup: return "ClinicStethoscope"
        case .visit: return "ClinicHospital"
        }
    }

    var description: String {
        switch self {
        case .checkup: return "定期検診・妊婦健診"
        case .visit: return "体調不良での受診"
        }
    }
}

// MARK: - LogEntry表示用Extension

extension LogEntry {
    /// タイムライン表示用のサマリーテキスト
    var summaryText: String {
        switch content {
        case .mood(let level):
            return level.displayText
        case .symptom(let types):
            return types.map { $0.rawValue }.joined(separator: "・")
        case .food(let items):
            return items.map { $0.rawValue }.joined(separator: "・")
        case .weight(let value):
            return String(format: "%.1f kg", value)
        case .hydration(let amount):
            return "\(amount) ml"
        case .clinic(let type, let hospitalName, _):
            if let name = hospitalName, !name.isEmpty {
                return "\(type.rawValue) \(name)"
            }
            return type.rawValue
        case .memo(let text):
            return text
        }
    }

    /// 時刻表示（HH:mm形式）
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
}
