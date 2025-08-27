# fcc

FCCの防犯アプリ

## Getting Started
- 本プロジェクトはFlutterで開発されています。
- 開発環境のセットアップには[Flutter公式ドキュメント](https://flutter.dev/docs/get-started/install)を参照してください。
- プロジェクトのクローン後、以下のコマンドで依存関係をインストールしてください。
  ```bash
  flutter pub get
  ```
- アプリのビルドと実行は以下のコマンドで行えます。
  ```bash
  flutter run
  ```  
- Androidエミュレータでのテストも可能です。 
## 作品概要
作品概要用は以下のリンクを参照してください。
- [作品概要](https://docs.google.com/document/d/1X3jv0y7Yk2b9JH1H5tY4g5Z6K8J9L0M1/edit?usp=sharing&ouid=115662785305703657490&rtpof=true&sd=true)

# 使用API
本プロジェクトでは、自前のAPIを使用しています。APIのソースコードは以下のリポジトリで公開されています。
- [APIリポジトリ](https://github.com/Protoproject-2/RealTime_Treatment_AND_Keyword_Detection.git)
- APIのセットアップと使用方法については、上記リポジトリのREADMEを参照してください。
- APIのエンドポイントはアプリ内で使用されているため、APIを起動した後にアプリを実行してください。

# 使用技術
本プロジェクトでは、以下の技術を使用しています。
- Flutter: クロスプラットフォームのモバイルアプリ開発フレームワーク
- Dart: Flutterで使用されるプログラミング言語
- Android Studio: 開発環境
- さくらのクラウド: APIホスティング

## コード規約 / Lint（flutter_lints）
本プロジェクトは公式推奨の `flutter_lints` を使用してコード品質とスタイルを統一しています。

### ルール定義
- ルートの `analysis_options.yaml` にて `flutter_lints` を継承しています。
- 重い生成物などは解析対象から除外しています。

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - .dart_tool/**

linter:
  rules:
    # ここでプロジェクト方針に合わせて個別に上書き可能
    # 例)
    # avoid_print: false
    # prefer_single_quotes: true
    # always_use_package_imports: true
```

補足:
- `pubspec.yaml` の `dev_dependencies` に `flutter_lints: ^3.0.0` を指定しています。
- `custom_lint` / `riverpod_lint` も導入済みのため、IDE 上で追加の診断が表示される場合があります。

### 実行方法
- 解析を実行: `flutter analyze`（Dart パッケージのみなら `dart analyze`）
- 自動修正を適用: `dart fix --apply`
  - 自動修正は意味等価な安全な変更のみを適用します。
  - 適用可能な変更がない場合は「Nothing to fix!」と表示されます。

### よくある指摘と対応方針
- avoid_print: 本番コードでの `print` は禁止。`dart:developer` の `log`、もしくはロガー（例: `logger`）へ置換。
- deprecated_member_use（`Color.withOpacity`）: `withOpacity` は非推奨。`withValues(alpha: ...)` へ置換し、見た目の差分は軽微か確認。
- use_build_context_synchronously: 非同期処理後に `BuildContext` を使う前に `if (!context.mounted) return;` を挿入。
- unnecessary_* 系: 不要な `toList` や括弧/補間は削除。

### ルールの一時無効化
- 行単位: `// ignore: ルール名`
- ファイル単位: ファイル先頭に `// ignore_for_file: ルール名`
  - 恒常的な無効化は推奨しません。可能な限りコード側で修正してください。

### CI でのチェック（任意）
GitHub Actions の例:

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
- 変更前にブランチを作成（例: `chore/flutter-lints-config`）。
- 変更後に `flutter analyze` → `dart fix --apply` → 再度 `flutter analyze` で確認。
- 可能なら PR でレビュー時にも解析が通っていることを確認。
