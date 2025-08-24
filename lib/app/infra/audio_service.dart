import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;

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

/// 音声の録音、バッファリング、アップロードを行うサービスクラス。
class AudioService {
  final Ref _ref;
  final _audioRecorder = AudioRecorder(); // 録音用インスタンス
  StreamSubscription? _recorderSubscription; // 録音ストリームの購読を管理
  final List<int> _audioBuffer = []; // 録音データを一時的に溜めるバッファ
  Timer? _timer; // 5秒ごとにアップロードをトリガーするためのタイマー

  // --- 音声設定 ---
  static const _sampleRate = 16000; // サンプルレート (Hz)
  static const _numChannels = 1; // チャンネル数 (モノラル)
  static const _bitDepth = 16; // ビット深度 (16-bit)

  AudioService(this._ref);

  /// 録音を開始する。
  Future<void> startRecording() async {
    // マイクの使用許可を確認
    if (!await _audioRecorder.hasPermission()) {
      print("マイクの使用が許可されていません。");
      return;
    }

    // 録音状態を「録音中」に更新
    _ref.read(isRecordingProvider.notifier).set(true);

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
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _uploadAudioChunk());
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
  }

  /// バッファに溜まった音声データをチャンク（塊）としてアップロードする。
  ///
  /// api.mdの仕様に基づき、ヘッダなしのraw PCMデータをPOSTリクエストのボディに含めて送信する。
  Future<void> _uploadAudioChunk() async {
    if (_audioBuffer.isEmpty) return; // バッファが空なら何もしない

    // バッファのデータをUint8Listに変換し、元のバッファはクリアする
    // ※注意: アップロード失敗時にデータが失われるため、堅牢な実装では送信成功後にクリアすべき
    final rawPcmData = Uint8List.fromList(_audioBuffer);
    _audioBuffer.clear();

    final uri = Uri.parse('https://fccapi.ddns.net/detect/keyword');
    final headers = {'Content-Type': 'application/octet-stream'};

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: rawPcmData,
      );

      if (response.statusCode == 200) {
        print('音声チャンクのアップロードに成功しました。');
        // レスポンスボディをUTF-8でデコードして表示
        print('Response: ${response.body}');
      } else {
        print('音声チャンクのアップロードに失敗しました: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('音声チャンクのアップロード中にエラーが発生しました: $e');
      // TODO: 再送メカニズムを実装することを検討
      // 例: _audioBuffer.insertAll(0, rawPcmData);
    }
  }
}