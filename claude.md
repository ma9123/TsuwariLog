# つわりログ（TsuwariLog）

妊娠中のつわり・体調を、しんどい時でも数タップで記録できるライフログアプリ

## 技術スタック

- **UI**: SwiftUI (iOS 17+)
- **状態管理**: @Observable
- **データ永続化**: SwiftData (iOS 17+)
- **アーキテクチャ**: シンプルなMVVM

## 開発フェーズ

- ✅ **Phase 1 - UIプロトタイプ** （完了）
- 🚧 **Phase 2 - SwiftData統合** （進行中）

### Phase 2の実装内容

1. **モデルをSwiftData対応に変更**
   - `LogEntry`を`@Model`に変換
   - `LogContent`をCodable対応
   - リレーションシップの設定

2. **データストアの実装**
   - `ModelContainer`のセットアップ
   - `@Query`でデータ取得
   - CRUD操作の実装

3. **既存UIとの統合**
   - サンプルデータを削除
   - 永続化されたデータを表示

## 画面構成

1. **TimelineView** - 起動時のメイン画面。記録をカード形式で時系列表示
2. **CategorySelectionSheet** - +ボタンで表示するボトムシート。7カテゴリから選択
3. **各Entry画面** - カテゴリごとの入力UI

## 7つの記録カテゴリ

| カテゴリ | 入力形式 | パステルカラー |
|---------|---------|--------------|
| 気分 | 5段階選択 | 黄色 |
| 症状 | チェックボックス（複数選択） | ピンク |
| 食べられた | グリッド選択（複数選択） | ベージュ |
| 体重 | 数値入力（テンキー） | 緑 |
| 水分 | 数値入力（テンキー＋クイック入力） | 水色 |
| 通院・健診 | 2択＋テキスト入力 | 薄紫 |
| メモ | テキスト入力 | グレー |

## デザイン方針

- 白い大きな角丸カード
- 薄いグレー背景
- 淡いパステルカラー
- 広い余白
- 2D・フラット・優しいイラスト風アイコン（影なし）
- 参考: アプリ「きろく」のタイムライン型UI

## UXの重要ポイント

- 「今日の記録」専用画面は作らない
- 起動時はタイムラインを表示
- 右下の＋から記録カテゴリを選択
- 同じ日に複数カテゴリを記録できる
- 各記録には記録時刻を保持する

## ディレクトリ構造

```
TsuwariLog/
├── TsuwariLogApp.swift
├── Design/
│   ├── Colors.swift
│   ├── DesignConstants.swift
│   └── FontStyle.swift
├── Models/
│   ├── RecordCategory.swift
│   ├── LogEntry.swift (SwiftData @Model)
│   └── LogStore.swift (削除予定)
├── Views/
│   ├── Timeline/
│   ├── CategorySelection/
│   └── Entry/
├── Components/
│   ├── CategoryIcon.swift
│   ├── FloatingAddButton.swift
│   ├── EntryHeader.swift
│   ├── NumericKeypad.swift
│   └── HintBox.swift
└── Assets.xcassets/
    ├── MoodVeryGood.imageset
    ├── MoodGood.imageset
    ├── MoodNormal.imageset
    ├── MoodBad.imageset
    ├── MoodVeryBad.imageset
    ├── ClinicStethoscope.imageset
    └── ClinicHospital.imageset
```

## コーディング規約

- SwiftUI標準のコーディングスタイルに従う
- View は小さく分割し、再利用可能にする
- Preview を必ず用意する
- 日本語コメントOK
