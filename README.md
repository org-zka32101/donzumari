# 宅配ドン詰まり (Donzumari)

日本の宅配・再配達あるあるを、コミカルな対戦体験に変換したバランス積みゲーム。

## 概要

- **ゲームタイプ**: バランス積み + 非同期ゴースト対戦
- **プラットフォーム**: iOS / Android
- **技術スタック**: Flutter 3.x + Flame 2.x + Riverpod + Firebase

## 主な機能

### Must (v1.0)
- 物理バランス積みコア（タップ/ドラッグ配置）
- ゴースト非同期対戦（他プレイヤーの玄関に積み足す）
- 崩落演出（クレーム電話/再配達コミカル演出）
- スコア比較・ランキング
- 荷物バリエーション（手動プリセット20種+色違い）
- 訪問先マッチング（複合スコア+NPCフォールバック）

### Should (v1.0)
- ニアミス可視化
- 配達員スキン課金

### Could (未定)
- 季節荷物イベント
- フレンド限定玄関

## 画面構成（7画面）

1. **スプラッシュ** - アプリ起動画面
2. **ホーム** - 自分の玄関・各機能へのメニュー
3. **プレイ画面** - コアゲーム（積む）
4. **結果画面** - スコア表示・共有・リトライ
5. **訪問先選択** - ゴースト対戦の候補3件提示
6. **ランキング** - 同一玄関の高さ争い
7. **ショップ** - 配達員/荷物スキン購入
8. **設定** - SE/BGM/通知/アカウント

## 開発体制

- **アーキテクチャ**: MVVM + Riverpod (Provider)
- **状態管理**: Riverpod (Freezed + freezed_annotation)
- **物理演算**: Flame Forge2D
- **バックエンド**: Firebase (Firestore/Auth/Analytics/Crashlytics/FCM/Remote Config)
- **課金**: RevenueCat（コスメティック課金）
- **ローカライゼーション**: 日本語のみ（宅配あるあるは日本特化）

## セットアップ

### 前提条件
- Flutter 3.0+
- Dart 3.0+
- Firebase プロジェクト

### インストール

```bash
# 依存関係をインストール
flutter pub get

# コード生成（Freezed / Riverpod）
flutter pub run build_runner build

# アプリを実行
flutter run
```

## プロジェクト構造

```
lib/
├── main.dart                 # エントリーポイント
├── core/                     # 定数・ユーティリティ
│   ├── constants/
│   ├── extensions/
│   └── utils/
├── data/                     # データ層
│   ├── models/               # Freezed で定義されたデータモデル
│   ├── repositories/         # Firebase との通信
│   └── providers/            # データプロバイダ
├── domain/                   # ビジネスロジック層
│   ├── services/             # 物理演算・マッチング等のサービス
│   └── providers/            # ビジネスロジックプロバイダ
└── presentation/             # UI層
    ├── screens/              # 7つの画面
    ├── widgets/              # 再利用可能なウィジェット
    └── providers/            # UI プロバイダ

assets/
├── parcels/                  # 荷物スプライト
├── audio/                    # BGM・SE
└── animations/               # Lottie アニメーション
```

## データモデル

### User
- uid, displayName, doorwayId, streak, ownedSkins[], createdAt

### Doorway（玄関）
- doorwayId, ownerUid, currentStack[], topScore, lastVisitedBy, lastActivityAt

### Parcel（荷物プリセット）
- parcelId, shape, stabilityTier, weight, rarity, seasonTag, spriteRef

### PlayResult
- resultId, uid, doorwayId, height, collapsed, gifRef, playedAt

### Ranking
- doorwayId, entries[{uid, height, rank}]

## KPI / OKR

### Objective
初回15秒でAhaに到達させ、非同期対戦で「あと1回」ループを定着させる

### Key Results
- KR1: Day1 リテンション 25-28%
- KR2: Day7 リテンション 15-18%
- KR3: Viral Coefficient 0.4+（崩落/最高到達シェア経由）
- KR4: 広告視聴によるリトライ率 40%+

## Aha Moment

「自分の玄関に他人が積んだ荷物を発見し、続きを積んで崩さず超える」体験

### 復帰トリガー
「あなたの玄関に新しい荷物が届きました」通知（他人が積み足した時）

## リリース戦略

### ソフトローンチ
- Android Play 内部テスト先行
- ゲート: Day1 ≥25% / クラッシュフリー ≥99.5% / Aha到達率 ≥60%

### 本公開
- iOS App Store / Google Play
- ストア審査対策: ATT・プライバシーマニフェスト・全年齢向け表記

## ロードマップ

### v1.1
- 崩落GIF自動生成→ワンタップ共有
- 住人リアクション演出（コミカルSD）

### v1.2
- 再配達ルーレット崩落
- 季節便シーズン制
- 証言システム

### v2.0
- 置き配テロ
- 町内会ランキング

### v2.1
- リレー便（積み継ぎチェーン）

## ライセンス

MIT