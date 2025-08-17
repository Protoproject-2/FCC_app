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
  Future<void> _uploadAudioChunk() async {
    if (_audioBuffer.isEmpty) return; // バッファが空なら何もしない

    // バッファのデータをコピーし、元のバッファはクリアする
    // ※注意: アップロード失敗時にデータが失われるため、堅牢な実装では送信成功後にクリアすべき
    final audioData = List<int>.from(_audioBuffer);
    _audioBuffer.clear();

    // PCMデータをWAV形式にエンコード
    final wavData = _encodeToWav(Uint8List.fromList(audioData));

    // TODO: 実際のサーバーURLに置き換える必要があります
    final uri = Uri.parse('https://example.com/upload');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'audio', // サーバー側で受け取る際のフィールド名
        wavData,
        filename: 'recording_${DateTime.now().millisecondsSinceEpoch}.wav',
      ));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print('音声チャンクのアップロードに成功しました。');
      } else {
        final responseBody = await response.stream.bytesToString();
        print('音声チャンクのアップロードに失敗しました: ${response.statusCode}, Body: $responseBody');
      }
    } catch (e) {
      print('音声チャンクのアップロード中にエラーが発生しました: $e');
      // TODO: 再送メカニズムを実装することを検討
      // 例: _audioBuffer.insertAll(0, audioData);
    }
  }

  /// 生のPCM音声データをWAVファイル形式のバイトデータにエンコードする。
  Uint8List _encodeToWav(Uint8List pcmData) {
    final pcmLength = pcmData.length;
    final header = ByteData(44); // WAVヘッダは44バイト
    final wavData = Uint8List(44 + pcmLength);

    const blockAlign = (_numChannels * _bitDepth) ~/ 8;
    final byteRate = _sampleRate * blockAlign;

    // --- WAVヘッダの各フィールドを設定 ---

    // "RIFF" チャンク
    header.setUint8(0, 0x52); // 'R'
    header.setUint8(1, 0x49); // 'I'
    header.setUint8(2, 0x46); // 'F'
    header.setUint8(3, 0x46); // 'F'
    header.setUint32(4, pcmLength + 36, Endian.little); // ファイルサイズ - 8

    // "WAVE" フォーマット
    header.setUint8(8, 0x57); // 'W'
    header.setUint8(9, 0x41); // 'A'
    header.setUint8(10, 0x56); // 'V'
    header.setUint8(11, 0x45); // 'E'

    // "fmt " チャンク (フォーマット情報)
    header.setUint8(12, 0x66); // 'f'
    header.setUint8(13, 0x6d); // 'm'
    header.setUint8(14, 0x74); // 't'
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little); // fmtチャンクのサイズ (16 for PCM)
    header.setUint16(20, 1, Endian.little);  // 音声フォーマット (1 for PCM)
    header.setUint16(22, _numChannels, Endian.little); // チャンネル数
    header.setUint32(24, _sampleRate, Endian.little); // サンプルレート
    header.setUint32(28, byteRate, Endian.little); // データ速度 (Byte/sec)
    header.setUint16(32, blockAlign, Endian.little); // ブロックサイズ (Byte/sample)
    header.setUint16(34, _bitDepth, Endian.little); // ビット深度

    // "data" チャンク (波形データ)
    header.setUint8(36, 0x64); // 'd'
    header.setUint8(37, 0x61); // 'a'
    header.setUint8(38, 0x74); // 't'
    header.setUint8(39, 0x61); // 'a'
    header.setUint32(40, pcmLength, Endian.little); // 波形データのサイズ

    // ヘッダとPCMデータを結合してWAVデータを作成
    wavData.setAll(0, header.buffer.asUint8List());
    wavData.setAll(44, pcmData);

    return wavData;
  }
}