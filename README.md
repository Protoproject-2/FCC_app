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
- 連携API: https://github.com/Protoproject-2/RealTime_Treatment_AND_Keyword_Detection

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
- https://docs.google.com/document/d/1X3jv0y7Yk2b9JH1H5tY4g5Z6K8J9L0M1/edit?usp=sharing

---
本READMEは開発者向けドキュメントです。改善提案や追加情報があればPRを歓迎します。
