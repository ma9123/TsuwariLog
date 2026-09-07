# つわりログ（TsuwariLog）

妊娠中のつわり・体調を、しんどい時でも数タップで記録できるライフログアプリ

## 技術スタック

- **UI**: SwiftUI (iOS 17+)
- **状態管理**: @Observable, @Query
- **データ永続化**: SwiftData (iOS 17+)
- **アーキテクチャ**: シンプルなMVVM

## 開発フェーズ

- ✅ **Phase 1 - UIプロトタイプ** （完了）
- ✅ **Phase 2 - SwiftData統合** （完了）

### Phase 2の実装内容

1. **モデルをSwiftData対応に変更**
   - `LogEntry`を`@Model`クラスに変換
   - `LogContent`をCodable対応（手動実装）
   - `contentData: Data`で保存、計算プロパティで`LogContent`にアクセス

2. **データストアの実装**
   - `TsuwariLogApp`で`ModelContainer`セットアップ
   - `TimelineView`で`@Query`を使用してデータ取得
   - 各Entry画面で`ModelContext.insert()`で保存

3. **日付・時刻選択機能**
   - `EntryHeader`に日付タップで`DateTimePickerSheet`を表示
   - グラフィカルなカレンダーUIで過去の記録も入力可能

## 画面構成

1. **TimelineView** - 起動時のメイン画面。記録をカード形式で時系列表示
2. **CategorySelectionSheet** - +ボタンで表示するボトムシート。7カテゴリから選択
3. **各Entry画面** - カテゴリごとの入力UI（日付・時刻選択可能）

## 7つの記録カテゴリ

| カテゴリ | 入力形式 | パステルカラー | カスタムアイコン |
|---------|---------|--------------|----------------|
| 気分 | 5段階選択 | 黄色 | MoodVeryGood〜MoodVeryBad |
| 症状 | カード選択（複数選択） | ピンク | MemoKarte（カルテ） |
| 食べられた | グリッド選択（複数選択） | ベージュ | FoodOnigiri〜FoodOther（12種） |
| 体重 | 数値入力（テンキー） | 緑 | WeightScale |
| 水分 | 数値入力（テンキー＋クイック入力） | 水色 | SF Symbols |
| 通院・健診 | 2択＋テキスト入力 | 薄紫 | ClinicStethoscope, ClinicHospital |
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

## UXの重要ポイント

- 「今日の記録」専用画面は作らない
- 起動時はタイムラインを表示
- 右下の＋から記録カテゴリを選択
- 同じ日に複数カテゴリを記録できる
- 各記録には記録時刻を保持する
- 日付・時刻をタップして過去の記録も入力可能

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
│   └── DateExtensions.swift (Date extension)
├── Views/
│   ├── Timeline/
│   │   └── TimelineView.swift
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
│   ├── EntryHeader.swift (DateTimePickerSheet含む)
│   ├── NumericKeypad.swift
│   └── HintBox.swift
└── Assets.xcassets/
    ├── 気分アイコン/
    │   ├── MoodVeryGood.imageset
    │   ├── MoodGood.imageset
    │   ├── MoodNormal.imageset
    │   ├── MoodBad.imageset
    │   └── MoodVeryBad.imageset
    ├── 症状アイコン/
    │   └── MemoKarte.imageset（カルテ）
    ├── 食べ物アイコン/
    │   ├── FoodOnigiri.imageset
    │   ├── FoodUdon.imageset
    │   ├── FoodBread.imageset
    │   ├── FoodRice.imageset
    │   ├── FoodKaraage.imageset
    │   ├── FoodMeat.imageset
    │   ├── FoodEgg.imageset
    │   ├── FoodDairy.imageset
    │   ├── FoodBanana.imageset
    │   ├── FoodFruit.imageset
    │   ├── FoodJelly.imageset
    │   └── FoodOther.imageset
    ├── 体重アイコン/
    │   └── WeightScale.imageset
    └── 通院アイコン/
        ├── ClinicStethoscope.imageset
        └── ClinicHospital.imageset
```

## コーディング規約

- SwiftUI標準のコーディングスタイルに従う
- View は小さく分割し、再利用可能にする
- Preview を必ず用意する（ModelContainerをメモリ内で作成）
- 日本語コメントOK
