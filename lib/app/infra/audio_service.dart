import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:fcc/app/infra/local_notification_service.dart';


part 'audio_service.g.dart';

@riverpod
AudioService audioService(Ref ref) {
  return AudioService(ref);
}

@riverpod
class IsRecording extends _$IsRecording {
  @override
  bool build() => false;

  void set(bool value) {
    state = value;
  }
}

@riverpod
class KeywordDetected extends _$KeywordDetected {
  @override
  bool build() => false;

  void set(bool value) {
    state = value;
  }
}

/// 音声の録音、バッファリング、アップロードを行うサービスクラス。
class AudioService {
  final Ref _ref;
  final _audioRecorder = AudioRecorder(); // 録音用インスタンス
  StreamSubscription? _recorderSubscription; // 録音ストリームの購読を管理
  final List<int> _audioBuffer = []; // 録音データを一時的に溜めるバッファ
  Timer? _timer; // 5秒ごとにアップロードをトリガーするためのタイマー
  dynamic _keepAlive;

  // アップロード制御用
  final List<Uint8List> _pendingChunks = []; // 未送信/再送待ちのチャンク
  bool _isUploading = false;                 // 送信中フラグ（並列送信を防ぐ）
  int _retryDelayMs = 1000;                  // 再試行ディレイ（指数バックオフ、最大15秒）
  static const int _retryDelayMaxMs = 15000;

  // --- 音声設定 ---
  static const _sampleRate = 16000; // サンプルレート (Hz)
  static const _numChannels = 1; // チャンネル数 (モノラル)
  static const _bitDepth = 16; // ビット深度 (16-bit)

  AudioService(this._ref) {
    _ref.onDispose(() async {
      _timer?.cancel();
      await _recorderSubscription?.cancel();
      await _audioRecorder.stop();
      _keepAlive?.close();
      _keepAlive = null;
      _pendingChunks.clear();
      _isUploading = false;
    });
  }

  /// 録音を開始する。
  Future<void> startRecording() async {
    // 録音中はautoDisposeで破棄されないよう延命
    _keepAlive ??= _ref.keepAlive();

    // マイクの使用許可を確認
    if (!await _audioRecorder.hasPermission()) {
      print("マイクの使用が許可されていません。");
      return;
    }

    _ref.read(isRecordingProvider.notifier).set(true);

    if (!_ref.mounted) return;

    // 録音設定を指定してストリームを開始
    final stream = await _audioRecorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits, // 16-bit PCM形式でエンコード
        sampleRate: _sampleRate,
        numChannels: _numChannels,
      ),
    );

    // ストリームを購読し、データが来るたびにバッファに追加
    _recorderSubscription = stream.listen(
      (data) => _audioBuffer.addAll(data),
      onError: (error) {
        print("録音ストリームでエラーが発生しました: $error");
        stopRecording(); // エラー発生時は録音を停止
      },
    );

    // 5秒ごとに_uploadAudioChunkメソッドを呼び出すタイマーを開始
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_ref.mounted) return;
      _uploadAudioChunk();
    });
  }

  /// 録音を停止する。
  Future<void> stopRecording() async {
    _timer?.cancel(); // タイマーをキャンセル
    await _recorderSubscription?.cancel(); // ストリームの購読をキャンセル
    await _audioRecorder.stop(); // 録音を停止
    _ref.read(isRecordingProvider.notifier).set(false); // 録音状態を「停止中」に更新

    // バッファにまだ送信されていないデータが残っていれば、最後にアップロード
    if (_audioBuffer.isNotEmpty) {
      _uploadAudioChunk();
    }

    _keepAlive?.close();
    _keepAlive = null;
  }

  /// バッファに溜まった音声データをチャンク（塊）としてアップロードする。
  ///
  /// api.mdの仕様に基づき、ヘッダなしのraw PCMデータをPOSTリクエストのボディに含めて送信する。
  Future<void> _uploadAudioChunk() async {
    if (!_ref.mounted) return;
    if (_audioBuffer.isEmpty) return;

    // 1) いま溜まっている分をチャンク化して pending キューへ移す（ここでは破棄しない）
    final chunk = Uint8List.fromList(_audioBuffer);
    _audioBuffer.clear(); // 以降は pending 側が責任を持つ
    _pendingChunks.add(chunk);

    // 2) 非並列で送信ループを回す
    if (_isUploading) return;
    _isUploading = true;
    try {
      while (_pendingChunks.isNotEmpty && _ref.mounted) {
        final next = _pendingChunks.first;

        final uri = Uri.parse('https://fccapi.ddns.net/detect/keyword');
        final headers = {'Content-Type': 'application/octet-stream'};

        try {
          final response = await http.post(uri, headers: headers, body: next);
          if (response.statusCode == 200) {
            // 送信成功：このチャンクを破棄（=確定）
            _pendingChunks.removeAt(0);
            _retryDelayMs = 1000; // バックオフをリセット
            // 任意: レスポンス表示
            print('Upload OK: ${response.body}');

            // レスポンスをパースして状態を更新
            try {
              final decoded = jsonDecode(response.body);
              if (decoded is Map<String, dynamic> &&
                  decoded['keyword_detected'] == true) {
                // 状態更新
                _ref.read(keywordDetectedProvider.notifier).set(true);

                // 通知サービスを呼び出し
                _ref
                    .read(localNotificationServiceProvider)
                    .showKeywordDetectedNotification();

                // 一度検知したらリセットする（必要に応じて）
                Future.delayed(const Duration(seconds: 1), () {
                  if (!_ref.mounted) return;
                  _ref.read(keywordDetectedProvider.notifier).set(false);
                });
              }
            } catch (e) {
              print('Failed to parse response: $e');
            }
          } else {
            // 送信失敗：チャンクは残したままバックオフして再試行
            print('Upload NG: ${response.statusCode} body=${response.body}');
            await Future.delayed(Duration(milliseconds: _retryDelayMs));
            _retryDelayMs = (_retryDelayMs * 2).clamp(1000, _retryDelayMaxMs);
            // while の先頭に戻り同じ first を再送
          }
        } catch (e) {
          // ネットワーク例外等：チャンクは残す → バックオフして再試行
          print('Upload error: $e');
          await Future.delayed(Duration(milliseconds: _retryDelayMs));
          _retryDelayMs = (_retryDelayMs * 2).clamp(1000, _retryDelayMaxMs);
        }
      }
    } finally {
      _isUploading = false;
    }
  }
}