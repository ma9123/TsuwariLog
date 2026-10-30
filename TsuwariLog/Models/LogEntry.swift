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

    /// 症状（複数選択可・「その他」は自由記述）
    case symptom(types: [SymptomType], otherText: String?)

    /// 食べられた（複数選択可・「その他」は自由記述）
    case food(items: [FoodItem], otherText: String?)

    /// 体重
    case weight(value: Double)

    /// 水分
    case hydration(amount: Int)

    /// 通院・健診
    case clinic(type: ClinicType, hospitalName: String?, note: String?, prescription: String?)

    /// メモ
    case memo(text: String)

    // Codable実装
    private enum CodingKeys: String, CodingKey {
        case type, level, types, items, value, amount, clinicType, hospitalName, note, text, otherText, prescription
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
            let otherText = try container.decodeIfPresent(String.self, forKey: .otherText)
            self = .symptom(types: types, otherText: otherText)
        case .food:
            let items = try container.decode([FoodItem].self, forKey: .items)
            let otherText = try container.decodeIfPresent(String.self, forKey: .otherText)
            // 旧項目の統合（バナナ→果物など）で生じた重複を取り除く
            var seen = Set<FoodItem>()
            let uniqueItems = items.filter { seen.insert($0).inserted }
            self = .food(items: uniqueItems, otherText: otherText)
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
            let prescription = try container.decodeIfPresent(String.self, forKey: .prescription)
            self = .clinic(
                type: clinicType,
                hospitalName: hospitalName,
                note: note,
                prescription: prescription
            )
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
        case .symptom(let types, let otherText):
            try container.encode(ContentType.symptom, forKey: .type)
            try container.encode(types, forKey: .types)
            try container.encodeIfPresent(otherText, forKey: .otherText)
        case .food(let items, let otherText):
            try container.encode(ContentType.food, forKey: .type)
            try container.encode(items, forKey: .items)
            try container.encodeIfPresent(otherText, forKey: .otherText)
        case .weight(let value):
            try container.encode(ContentType.weight, forKey: .type)
            try container.encode(value, forKey: .value)
        case .hydration(let amount):
            try container.encode(ContentType.hydration, forKey: .type)
            try container.encode(amount, forKey: .amount)
        case .clinic(let type, let hospitalName, let note, let prescription):
            try container.encode(ContentType.clinic, forKey: .type)
            try container.encode(type, forKey: .clinicType)
            try container.encodeIfPresent(hospitalName, forKey: .hospitalName)
            try container.encodeIfPresent(note, forKey: .note)
            try container.encodeIfPresent(prescription, forKey: .prescription)
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
    case other = "その他"

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
        case .other: return "ellipsis.circle"
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
        case .other: return .gray
        }
    }
}

// MARK: - 食べ物アイテム

enum FoodItem: String, CaseIterable, Identifiable, Codable {
    case onigiri = "おにぎり"
    case noodles = "麺類"
    case bread = "パン"
    case rice = "ごはん"
    case karaage = "唐揚げ"
    case meat = "肉・揚げ物"
    case egg = "卵"
    case dairy = "乳製品"
    case fruit = "果物"
    case jelly = "ゼリー"
    case other = "その他"

    var id: String { rawValue }

    /// 旧バージョンで保存された値との対応（項目名の変更・削除に追従するため）
    private static let legacyRawValues: [String: FoodItem] = [
        "うどん": .noodles,  // 麺類に統合
        "バナナ": .fruit     // 項目を削除したため果物に寄せる
    ]

    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        self = FoodItem(rawValue: rawValue)
            ?? FoodItem.legacyRawValues[rawValue]
            ?? .other
    }

    var iconName: String {
        switch self {
        case .onigiri: return "triangle.fill"
        case .noodles: return "oval.fill"
        case .bread: return "oval.portrait.fill"
        case .rice: return "circle.fill"
        case .karaage: return "square.fill"
        case .meat: return "rectangle.fill"
        case .egg: return "oval.fill"
        case .dairy: return "cup.and.saucer.fill"
        case .fruit: return "apple.logo"
        case .jelly: return "drop.fill"
        case .other: return "ellipsis"
        }
    }

    var customImageName: String {
        switch self {
        case .onigiri: return "FoodOnigiri"
        case .noodles: return "FoodUdon"  // うどんのイラストを麺類として流用
        case .bread: return "FoodBread"
        case .rice: return "FoodRice"
        case .karaage: return "FoodKaraage"
        case .meat: return "FoodMeat"
        case .egg: return "FoodEgg"
        case .dairy: return "FoodDairy"
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
        case .symptom(let types, let otherText):
            return types.map { type in
                if type == .other, let text = otherText, !text.isEmpty {
                    return "その他（\(text)）"
                }
                return type.rawValue
            }.joined(separator: "・")
        case .food(let items, let otherText):
            let freeText = otherText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            // 自由記述があれば「その他」の代わりにその内容を並べる
            var labels = items
                .filter { !($0 == .other && !freeText.isEmpty) }
                .map { $0.rawValue }
            if !freeText.isEmpty {
                labels.append(freeText)
            }
            return labels.joined(separator: "・")
        case .weight(let value):
            return String(format: "%.1f kg", value)
        case .hydration(let amount):
            return "\(amount) ml"
        case .clinic(let type, let hospitalName, _, let prescription):
            var text = type.rawValue
            if let name = hospitalName, !name.isEmpty {
                text += " \(name)"
            }
            if let medicine = prescription, !medicine.isEmpty {
                // 改行は読みやすさのため中黒に置き換える（CSV出力でも1セルに収まる）
                let singleLine = medicine
                    .split(separator: "\n")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                    .joined(separator: "・")
                text += "（処方：\(singleLine)）"
            }
            return text
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
