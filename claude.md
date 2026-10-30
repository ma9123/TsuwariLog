# つわり日記（TsuwariLog）

> アプリ表示名は「つわり日記」。`TsuwariLog` はプロジェクト／リポジトリ名。

妊娠中のつわり・体調を、しんどい時でも数タップで記録できるライフログアプリ

## 技術スタック

- **UI**: SwiftUI (iOS 17+)
- **状態管理**: @Observable, @Query, @AppStorage
- **データ永続化**: SwiftData (iOS 17+)
- **グラフ**: Swift Charts
- **通知**: UserNotifications
- **アーキテクチャ**: シンプルなMVVM

## 開発状況

**v1.0 リリース準備完了**

### 実装済み機能

1. **タイムライン表示**
   - 日付ごとにグループ化されたカード表示
   - 編集・削除機能（メニューから）
   - 空状態のフレンドリーなメッセージ
   - 妊娠週数バナー表示

2. **7カテゴリの記録入力**
   - 気分（5段階）、症状、食べられた、体重、水分、通院・健診、メモ
   - 日付・時刻選択で過去の記録も入力可能

3. **カレンダー表示**
   - 月間カレンダーに気分アイコン表示
   - 日付タップでタイムラインにジャンプ

4. **統計・まとめ画面**
   - 月別/週数別の切り替え表示
   - 気分分布、症状頻度、食べ物ランキング
   - 体重推移グラフ、水分合計、通院履歴

5. **設定画面**
   - 出産予定日設定（妊娠週数自動計算）
   - リマインダー通知（時刻設定可能）
   - CSVデータエクスポート
   - 全データ削除

6. **リマインダー通知**
   - 毎日指定時刻に通知
   - 3日以内の記録有無で文言を変更
   - アプリ起動時に再スケジュール

## 画面構成

```
TimelineView（メイン）
├── TimelineHeader（カレンダー/統計/設定ボタン）
├── PregnancyWeekBanner（妊娠週数表示）
├── TimelineEmptyState（記録なし時）
└── TimelineDateSection（日付ごとのカード）

CalendarView（カレンダー）
├── CalendarMonthSelector
└── CalendarDayCell（気分アイコン付き）

StatisticsView（まとめ）
├── モード切替（月/週数）
├── MonthSelector / WeekSelector
└── 6つのサマリーカード

SettingsView（設定）
├── 妊娠情報（出産予定日、週数）
├── リマインダー
├── データ管理
└── アプリ情報

各EntryView（記録入力）
└── EntryHeader（日付選択）
```

## 7つの記録カテゴリ

| カテゴリ | 入力形式 | パステルカラー | カスタムアイコン |
|---------|---------|--------------|----------------|
| 気分 | 5段階選択 | 黄色 | MoodVeryGood〜MoodVeryBad |
| 症状 | カード選択（複数選択・「その他」は自由記述） | ピンク | MemoKarte（カルテ） |
| 食べられた | グリッド選択（複数選択）＋自由記述 | ベージュ | FoodOnigiri〜FoodOther（11種） |
| 体重 | 数値入力（テンキー） | 緑 | WeightScale |
| 水分 | 数値入力（テンキー＋クイック入力） | 水色 | SF Symbols |
| 通院・健診 | 2択＋テキスト入力（病院名・処方薬・メモ） | 薄紫 | ClinicStethoscope, ClinicHospital |
| メモ | テキスト入力 | グレー | SF Symbols |

## デザイン方針

- 白い大きな角丸カード
- 薄いグレー背景
- 淡いパステルカラー
- 広い余白
- 2D・フラット・優しいイラスト風アイコン（影なし）
- SF Rounded フォント
- タイムラインのメモは普通の太さで表示
- 参考: アプリ「きろく」のタイムライン型UI

## ディレクトリ構造

```
TsuwariLog/
├── TsuwariLogApp.swift
├── ContentView.swift
├── Design/
│   ├── Colors.swift
│   ├── DesignConstants.swift
│   └── FontStyle.swift
├── Models/
│   ├── RecordCategory.swift
│   ├── LogEntry.swift (SwiftData @Model)
│   ├── UserSettings.swift (設定・通知管理)
│   └── DateExtensions.swift
├── Views/
│   ├── Timeline/
│   │   └── TimelineView.swift
│   ├── Calendar/
│   │   └── CalendarView.swift
│   ├── Statistics/
│   │   └── StatisticsView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   ├── CategorySelection/
│   │   └── CategorySelectionSheet.swift
│   └── Entry/
│       ├── MoodEntryView.swift
│       ├── SymptomEntryView.swift
│       ├── FoodEntryView.swift
│       ├── WeightEntryView.swift
│       ├── HydrationEntryView.swift
│       ├── ClinicEntryView.swift
│       └── MemoEntryView.swift
├── Components/
│   ├── CategoryIcon.swift
│   ├── FloatingAddButton.swift
│   ├── EntryHeader.swift
│   ├── NumericKeypad.swift
│   └── HintBox.swift
└── Assets.xcassets/
    └── (カスタムアイコン各種)
```

## リリース前TODO

- [ ] アプリアイコン設定
- [ ] Bundle Identifier設定
- [ ] プライバシーポリシー/利用規約URL設定（SettingsView.swiftのコメント解除）

## コーディング規約

- SwiftUI標準のコーディングスタイルに従う
- View は小さく分割し、再利用可能にする
- Preview を必ず用意する（ModelContainerをメモリ内で作成）
- 日本語コメントOK
