# Lint/静的解析ルールと運用方針

本ドキュメントは、FCCアプリにおける静的解析（Lint）のルール、CI 設定、運用方針をまとめたものです。

## 目的
- コード品質・一貫性の維持と、問題の早期発見。
- PR 時に自動チェックし、レビュー効率を高める。

## 対象と範囲
- 言語: Dart（Flutter）
- 対象: リポジトリ配下の Dart コード全体（生成物含む）
- 除外: 現時点では明示的な除外なし（`*.g.dart` 等の生成ファイルも対象）

## 参照ファイル
- `analysis_options.yaml` — ベースルール: `package:flutter_lints/flutter.yaml`
- CI ワークフロー: `.github/workflows/lint.yml`

## CI で実行するチェック
1. フォーマット差分の検出（未整形があると失敗）
   - コマンド: `dart format --output=none --set-exit-if-changed .`
2. 静的解析（info / warning を致命扱い）
   - コマンド: `dart analyze --fatal-infos --fatal-warnings`
3. 追加Lint（custom_lint／riverpod_lint など）
   - コマンド: `dart run custom_lint`

## 厳しさ（失敗条件）
- フォーマット: 1行でも未整形があれば失敗。
- 解析: info / warning を含め1件でもあれば失敗。
- custom_lint: プラグインが報告する違反が致命扱いの場合は失敗。

## ローカルでの実行方法
```bash
flutter pub get
dart format .
dart analyze
dart run custom_lint
```

CI と同等の厳しさで確認する場合は `dart analyze --fatal-infos --fatal-warnings` を使用してください。

## よくある調整事項
- 生成ファイルの除外（ノイズ低減）
  - 生成物が頻繁に指摘される場合は `analysis_options.yaml` に除外を追加します。
  - 例:
    ```yaml
    analyzer:
      exclude:
        - "**/*.g.dart"
        - "**/*.freezed.dart"
    ```
- 段階的導入（厳しさの段階調整）
  - 初期: `--fatal-warnings` のみ → 安定後に `--fatal-infos` を有効化。
  - 必要に応じて `analysis_options.yaml` でルールの無効化/有効化を行う。

## ルールのカスタマイズ
- `analysis_options.yaml` の `linter.rules` で明示的に ON/OFF を設定可能。
- 例（シングルクォートを強制）:
  ```yaml
  linter:
    rules:
      prefer_single_quotes: true
  ```

## 指摘の抑制（最小限に）
- 一行のみ無視: `// ignore: <rule_name>`
- ファイル全体で無視: 先頭に `// ignore_for_file: <rule_name>`
- 注意: 抑制は最終手段。まずは根本修正を検討してください。

## PR とブランチ運用
- CI トリガー: push（`main`, `feature/**`, `fix/**`）と全ての PR。
- 方針: すべての PR は Lint をパスすること。
- 例外が必要な場合は、理由を PR に明記したうえでレビュアーと合意すること。

## トラブルシュート
- 依存未取得: `flutter pub get` を再実行。
- Flutter SDK 不一致: ローカル SDK を stable 最新に更新（CI は `subosito/flutter-action@v2` で stable を使用）。
- custom_lint が動かない: `dev_dependencies` に `custom_lint` と関連プラグイン（例: `riverpod_lint`）が入っているか確認。

## 将来的な拡張
- Kotlin/Swift 等のプラットフォーム別 Lint を Actions に追加（`ktlint`, `swiftlint` など）。
- フォーマットの自動修正ジョブ追加や、PR コメントボットの導入。

