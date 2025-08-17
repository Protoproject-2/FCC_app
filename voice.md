


# GeminiCLIで「5秒おき音声アップロード」プロトタイプを作る方針とフロー

## 推奨アーキテクチャ（方式の選定）

- **方式2：連続録音→5秒ごとにスライスして送信（ローリングバッファ）**
  - 途切れがなく、タイミングの安定性が高い
  - 実装はやや増えるが、正確な5秒窓を再現しやすい
  - 送信はまず **HTTP（multipart/form-data で WAV/PCM）**、将来 **WebSocket/gRPC** に差し替え可能

---

## 事前準備

- Node.js v18+
- GeminiCLI の導入（グローバル）
  ```bash
  npm install -g @google/gemini-cli
  gemini  # 初回起動
  ```
- APIキー/認証の準備

---

## リポジトリ雛形

```
proto-audio-uploader/
├─ app/                     # クライアント
│  ├─ src/recording/        # 録音・バッファ処理
│  ├─ src/transport/        # 送信処理
│  └─ src/config/           # 設定
├─ server/                  # 受け口API
│  └─ routes/upload.ts
└─ docs/                    # 仕様・決定事項
```

---

## 開発フロー（GeminiCLIを軸に）

1. **雛形生成**  
   GeminiCLIに要件を伝え、クライアント/サーバのコードを生成
2. **録音ストリーム→5秒スライス**  
   サンプル数基準で区切り、WAV化して送信
3. **送信API**  
   `/audio` に multipart POST。後にWebSocket版も追加
4. **テスト＆反復**  
   ユニット→結合→実機テスト。GeminiCLIでテスト生成・修正を反復
5. **ドキュメント化**  
   DECISIONS.md と README.md に仕様・セットアップを明記

---

## 実行コマンド例

```bash
cd server && npm i && npm run dev
cd app && flutter run
gemini
```

---

## 設計チェックリスト

- [ ] サンプル数基準で5秒を区切る
- [ ] 残りバッファを終了時に送信
- [ ] 再送戦略とchunk_id
- [ ] サイズ制限
- [ ] iOS/Android 権限
- [ ] 無音時最適化（VAD）や Opus 化は次フェーズ