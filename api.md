# 🎤 detect/keyword 送信方針（クライアント → サーバ）

このドキュメントは、スマホアプリから `POST /detect/keyword` に音声データを送る際の **方針と要件** をまとめたものです。実装詳細ではなく「なにを・どう送るべきか」を明確にします。

---

## 1. エンドポイント概要

- **Base URL**: `https://fccapi.ddns.net`
- **URL**: `/detect/keyword`
- **HTTP Method**: `POST`
- **目的**: 合言葉検知（KeywordDetector）を実行し、検知結果・認識テキスト・マッチした合言葉を返す。

---

## 2. サーバ側の期待フォーマット（現状仕様）

サーバは `request.data` をそのまま `np.frombuffer(..., dtype=np.int16)` で読み込みます。  
よって **ヘッダ付き音声（WAV/MP3等）は想定していません**。

- サンプリングレート: **16,000 Hz**
- チャンネル: **モノラル (1ch)**
- 量子化: **16-bit PCM (Little Endian)**
- 送信形式: **ヘッダなしの raw PCM バイト列**
- HTTPヘッダ:  
  - `Content-Type: application/octet-stream`（必須）
  - （任意）`X-Sample-Rate: 16000`, `X-Format: PCM16LE` などメタ情報

> メモ: サーバ側で `EXPECTED_SAMPLE_RATE = 16000` を前提にしています。

### 2.1 実装根拠（サーバコード抜粋）

以下は、現仕様（**raw PCM / 16kHz / mono / 16-bit** を素のHTTPボディで受ける）を裏づけるコード抜粋です。あなたが提示した `Flask` サーバの実装から引用しています。

#### ■ サンプリングレート前提
```python
# 設計書で定められたサンプリングレート
# YAMNet (Scream) と Whisper (Keyword) は共に16000Hzを期待する
EXPECTED_SAMPLE_RATE = 16000
```
- **16,000 Hz を期待**していることが明示されています。

#### ■ HTTPボディから「ヘッダなしの生PCM」を読む
```python
# Rawバイナリデータを取得
audio_data_raw = request.data
# np.frombufferでNumPy配列に変換 (16bit整数として)
audio_data_np = np.frombuffer(audio_data_raw, dtype=np.int16)
# float32に正規化
audio_data_float = audio_data_np.astype(np.float32) / 32768.0
```
- `request.data` を **そのままバイト列**として取得。
- `np.frombuffer(..., dtype=np.int16)` で **16-bit PCM little-endian** として解釈。
- **WAV/MP3等のヘッダは一切パースしていない**ため、クライアントは**ヘッダなしのraw PCM**を送る必要があります。

この処理は `/detect/scream` と `/detect/keyword` の両エンドポイントで同様に行われています。

#### ■ 悲鳴検知および上位クラス取得（参考）
```python
is_scream, confidence = scream_detector.detect(audio_data_float, EXPECTED_SAMPLE_RATE)
top_classes = scream_detector.get_top_classes(audio_data_float, EXPECTED_SAMPLE_RATE)
```
- 推論入力として `float32` 正規化波形と `EXPECTED_SAMPLE_RATE` を使用。

#### ■ 合言葉検知の入力仕様（参考）
```python
detected, recognized_text, matched_keyword = keyword_detector.detect(audio_data_float, keyword_manager)
```
- 合言葉検知でも、**同じ前処理（raw→int16→float32）**を通った波形を想定しています。
- サーバ側では受信時点でサンプルレート検証・補正（リサンプリング）はしていないため、**クライアントで 16kHz/mono/PCM16 に揃える**のが安全です。

> まとめ: 以上のコードから、**(1) 16kHz**, **(2) mono**, **(3) PCM16LE**, **(4) ヘッダなしraw** をそのままHTTPボディに入れて送る、という方針が直接導かれます。

---

## 3. クライアント（スマホアプリ）側の送信方針

### A. 現状仕様に完全準拠（最短で動かす）
1. ライブラリの都合でまず **WAV(PCM16/16kHz/mono)** で録音してもOK  
2. **WAVヘッダを剥がし**、`data` チャンク（生PCM部分）だけを抽出  
3. 抽出した **raw PCM** をリクエストボディにそのまま入れて `POST`  
4. `Content-Type: application/octet-stream` を付与

**利点**: サーバ変更不要、今すぐ動く  
**注意**: WAVヘッダは一般に 44 bytes だが、メタ情報で長さが変わる場合あり。堅牢にやるなら RIFF をパースして `data` オフセットを取得すること。

---

### B. サーバ側を拡張し、WAVをそのまま受け入れる
1. サーバで `wave` 等を用いて **WAVヘッダを解釈** し、PCMデータを抽出  
2. 以降の処理は現行と同じ（`np.int16 → float32 正規化` → 検知）  
3. クライアントは **録音した WAV をそのまま送信**（`Content-Type: audio/wav`）

**利点**: クライアント実装が簡単・保守性が高い  
**コスト**: サーバに軽微な実装追加

---

### C. 圧縮コーデック（MP3/AAC等）を使う場合（将来案）
- クライアントの帯域・保存効率は良いが、サーバで **デコード処理**（例: `pydub/ffmpeg-python/torchaudio`）が必要。  
- リアルタイム性や遅延を考えると、当面は **非圧縮PCM（A or B）** を推奨。

---

## 4. 音声クリップの目安・品質

- **長さ**: 1〜2秒以上を推奨（短すぎると認識精度が落ちる）  
- **音量**: 小さすぎるとSNR低下。クリッピングは回避。  
- **無音トリム**: 先頭/末尾の無音を削ると有効長が増え、精度に寄与する場合あり。

---

## 5. エラーと再送

- **HTTP 400/409**: 入力不備や重複等（/keywords API 由来）。音声送信では **400番台はクライアント見直し**。  
- **HTTP 500**: サーバ内部エラー。**リトライ** する場合は指数バックオフ（例: 500ms → 1s → 2s）。  
- ネットワーク断に備え、**最大リトライ回数** と **タイムアウト** をクライアント側で設定。

---

## 6. 簡易な送信チェック（参考）

- テスト用に、ローカルで作った **raw PCM** を `curl` で送る:
  ```bash
  curl -X POST \
    -H "Content-Type: application/octet-stream" \
    --data-binary @sample_16k_mono_pcm16.raw \
    http://<HOST>:5000/detect/keyword
  ```
- WAVを送る場合は **B案（サーバ拡張）** 実装後に:
  ```bash
  curl -X POST \
    -H "Content-Type: audio/wav" \
    --data-binary @sample_16k_mono.wav \
    http://<HOST>:5000/detect/keyword
  ```

---

## 7. セキュリティと運用メモ

- **HTTPS** 推奨（本番）。開発中はHTTPでも可だが早期にTLS化を検討。  
- サイズ制限: クライアントは送信前に**最大秒数/バイト数**でクリップ（想定: 数MB未満）。  
- 将来の拡張: 連続ストリーミングが必要なら **chunked transfer / WebSocket / gRPC** を検討。

---

## 8. 推奨ロードマップ

1. **Phase 1**: A案でまず動作確認（raw PCM送信）  
2. **Phase 2**: サーバをB案に拡張（WAV受け入れ）→ クライアント実装を簡素化  
3. **Phase 3**: 圧縮送信・ストリーミング・ノイズ抑制など最適化を順次導入

以上で「なにを・どう送るか」の合意を明文化しました。実装に着手する前の **仕様確認用ドキュメント** として利用してください。

## 9. 実サーバ疎通・動作確認（`https://fccapi.ddns.net`）

### 9.1 スモークテスト
```bash
# 合言葉一覧（GET）
curl -sS https://fccapi.ddns.net/keywords | jq .
```
- 4xx/5xx が返る場合は、Nginx のリバースプロキシ設定や Flask/gunicorn の起動状況を確認。

### 9.2 サンプル音声での検知（ローカルから）
**WAV → raw PCM（16kHz/mono/PCM16）に変換して送信**：
```bash
# 例: input.wav を 16kHz/mono/PCM16 の raw に変換
ffmpeg -i input.wav -ac 1 -ar 16000 -f s16le -acodec pcm_s16le out.pcm

# 検知APIへ POST（raw）
curl -X POST \
  -H "Content-Type: application/octet-stream" \
  --data-binary @out.pcm \
  https://fccapi.ddns.net/detect/keyword
```

> 現状のサーバ実装は **ヘッダなし raw PCM** を想定。WAV をそのまま送りたい場合は「B. サーバ側を拡張」の対応が必要。

### 9.3 Flutter/Android 送信時の要点
- HTTPS 利用のため、Android の cleartext 設定は不要（自己署名証明書でない前提）。
- 送信ヘッダ: `Content-Type: application/octet-stream`
- ボディ: **WAVヘッダを剥がした raw PCM (16kHz/mono/16bit LE)**

送信骨子（Dart）：
```dart
final resp = await http.post(
  Uri.parse('https://fccapi.ddns.net/detect/keyword'),
  headers: {'Content-Type': 'application/octet-stream'},
  body: rawPcmBytes, // WAVヘッダを除いた生PCM
);
```

### 9.4 Nginx（参考設定）
推論時間やボディサイズに余裕を持たせる例：
```nginx
client_max_body_size 5m;

location / {
  proxy_read_timeout    300s;
  proxy_send_timeout    300s;
  proxy_connect_timeout  60s;
  proxy_http_version    1.1;
  proxy_set_header      Connection "";
  proxy_pass            http://127.0.0.1:5000;
}
```
> 本番運用は **gunicorn + 複数ワーカー** を推奨（例：`--workers 2 --threads 4`）。推論の同時処理数に合わせて調整。

### 9.5 すぐ使える確認用クリップ（1秒の440Hzを合成）
WAVが手元に無い場合の簡易テスト：
```bash
python3 - <<'PY'
import numpy as np
sr=16000; t=np.arange(0, sr)/sr
x=(0.2*np.sin(2*np.pi*440*t)).astype(np.float32)
pcm=(np.clip(x, -1, 1)*32768).astype(np.int16).tobytes()
open("tone_440_1s.pcm","wb").write(pcm)
PY

curl -X POST -H "Content-Type: application/octet-stream" \
  --data-binary @tone_440_1s.pcm \
  https://fccapi.ddns.net/detect/keyword
```