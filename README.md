<div align="center">

# FCC 防犯アプリ（Flutter）

端末の音声を解析し、特定の合言葉（キーワード）を検知した際にローカル通知を表示、
さらにLINE連携を活用してユーザ登録や招待URLの共有を行う防犯支援アプリです。

</div>

## 概要
- フレームワーク: Flutter / Dart (SDK >= 3.0.0)
- 状態管理: Flutter Riverpod 3 (generator/dev版利用)
- 主要機能:
  - 録音: 端末マイクからの音声収集（record）
  - 検知: サーバAPIに音声を送信して合言葉検知
  - 通知: 検知時にローカル通知（flutter_local_notifications）
  - 連携: LINE SDKによるログイン・ユーザ連携（flutter_line_sdk）
  - 共有: 招待URL生成・QRコード表示

## リポジトリ
- アプリ: https://github.com/Protoproject-2/FCC_app
- 連携API: 音声キーワード検知（サーバー）https://github.com/Protoproject-2/RealTime_Treatment_AND_Keyword_Detection
- 連携API: LINEログイン・ユーザ管理（サーバー）https://github.com/Protoproject-2/FCC_LINE_API.git
## ディレクトリ構成（抜粋）
```
lib/
  app/
    main.dart                  # エントリポイント（通知初期化・LINE SDKセットアップ・HomeUI）
    main_widgetbook.dart       # Widgetbook エントリー
    ui/home/*                  # 画面/UI/ビューモデル（Riverpod）
    infra/*                    # APIアクセス、録音、通知などのサービス
    domain/                    # ドメインモデル/リポジトリIF
```

## セットアップ
1) Flutter環境の用意（3系推奨）
- インストール手順: https://flutter.dev/docs/get-started/install

2) 依存関係の取得
```
flutter pub get
```

3) コード生成（Riverpod等）
```
dart run build_runner build --delete-conflicting-outputs
# 監視実行
dart run build_runner watch --delete-conflicting-outputs
```

## 実行方法
- 通常実行（デフォルトエントリ）
```
flutter run
```

- Widgetbook（UIカタログ）を起動
```
flutter run -t lib/app/main_widgetbook.dart
```

## プラットフォーム設定・権限
### Android
- `android/app/src/main/AndroidManifest.xml`
  - `RECORD_AUDIO`（マイク）
  - `POST_NOTIFICATIONS`（Android 13+ 通知許可）
  - `INTERNET`

### iOS
- `ios/Runner/Info.plist`
  - `NSMicrophoneUsageDescription`（マイク用途）
  - `NSLocalNotificationUsageDescription`（ローカル通知）
  - `UIBackgroundModes: remote-notification`
  - URLスキーム/クエリスキーム（LINE連携）

## 外部サービス連携
### LINE SDK
- 初期化: `lib/app/main.dart`
```
LineSDK.instance.setup('2007473247');
```
- iOS 設定: `Info.plist`
  - `CFBundleURLSchemes: line3rdp.$(PRODUCT_BUNDLE_IDENTIFIER)`
  - `LSApplicationQueriesSchemes: lineauth2`
- 注意: チャネルID/バンドルID/URLスキームは環境に合わせて変更してください。

### API 連携
- ベースURL: `https://fccapi.ddns.net`
- 音声キーワード検知
  - エンドポイント: `POST /detect/keyword`
  - 送信データ: 生PCM（raw PCM、ヘッダなし）
  - 例: `Content-Type: audio/L16` でボディにPCMバイト列を送信
- 招待URL生成
  - `GET /generate_invite/{userId}`
- ユーザ登録
  - `POST /get_id`（ボディ例: `{"name": "...", "line_user_id": "..."}`）
- QRコード生成
  - 外部API: `https://api.qrserver.com/v1/create-qr-code/?size=240x240&data=...`

## ビルド
- Android APK
```
flutter build apk
```
- iOS（署名設定が必要）
```
flutter build ios
```

## コード規約 / Lint（flutter_lints）
本プロジェクトでは公式推奨の `flutter_lints` を用いて、静的解析とコーディング規約を統一しています。

### ルール定義
- ルートの `analysis_options.yaml` で `flutter_lints` を継承します。必要に応じてルールを上書きできます。

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - .dart_tool/**

linter:
  rules:
    # 例: 個別に上書き/追加
    # avoid_print: false
    # prefer_single_quotes: true
    # always_use_package_imports: true
```

補足:
- `pubspec.yaml` の `dev_dependencies` に `flutter_lints` を指定（例: `^3.x`）。
- `custom_lint` / `riverpod_lint` も導入しているため、IDE 上で追加の診断が表示されることがあります。

### 実行方法
- 解析: `flutter analyze`（Dart パッケージのみなら `dart analyze`）
- 自動修正: `dart fix --apply`
  - 自動修正は意味等価な範囲のみが対象です。適用可能なものが無い場合は「Nothing to fix!」と表示されます。

### よくある指摘と対応
- avoid_print: 本番コードでの `print` は避け、`dart:developer` の `log` やロガー（例: `logger`）を使用。
- deprecated_member_use（`Color.withOpacity`）: 非推奨。`withValues(alpha: ...)` への移行を検討。
- use_build_context_synchronously: 非同期後に `BuildContext` を使う場合は、`if (!context.mounted) return;` を挿入。
- unnecessary_* 系: 不要な `toList`、括弧、補間は削除。

### 一時的な無効化
- 行単位: `// ignore: ルール名`
- ファイル単位: ファイル先頭に `// ignore_for_file: ルール名`
  - 恒久的な無効化は避け、できる限りコード修正で解決してください。

### CI 例（任意）
GitHub Actions で解析を自動チェックする例:

```yaml
name: analyze
on: [push, pull_request]
jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter analyze
```

### 開発フローの推奨
- ブランチを切る → 変更 → `flutter analyze` → 必要に応じ `dart fix --apply` → 再度 `flutter analyze` で確認 → PR 作成。

## トラブルシュート
- 通知が表示されない
  - Android 13+ では通知のランタイム許可が必要です。
  - アプリ初回起動時の許可ダイアログ、または設定から許可を付与してください。
- APIに到達できない
  - 端末から `https://fccapi.ddns.net` にアクセスできるか確認してください。
  - 自前APIが停止している場合はAPIリポジトリのREADMEに従い起動してください。
- LINE連携が失敗する
  - チャネルID・URLスキーム・バンドルID/アプリIDの整合性を確認してください。

## 作品概要資料
https://protopedia.net/prototype/private/ccbc8dde-a725-469e-916f-2c0d43ae8cc5

---
本READMEは開発者向けドキュメントです。改善提案や追加情報があればPRを歓迎します。
