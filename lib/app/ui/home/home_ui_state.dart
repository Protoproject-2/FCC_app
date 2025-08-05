import 'package:fcc/app/ui/home/home_ui_view_model.dart';

// UI層の状態を保持するためのクラス。
// ON/OFF状態や、合言葉のON/OFFスイッチの状態を一括して管理する。
class HomeUiState {
  final bool isDetecting; // 音声検知がONかOFFかの状態
  final List<KeywordToggle> keywordToggles; // 各合言葉のスイッチ状態

  const HomeUiState({
    this.isDetecting = false,
    required this.keywordToggles,
  });

  // 状態を部分的に更新するためのメソッド。
  // 引数が指定されたフィールドのみ更新され、それ以外は現状維持。
  HomeUiState copyWith({
    bool? isDetecting,
    List<KeywordToggle>? keywordToggles,
  }) {
    return HomeUiState(
      isDetecting: isDetecting ?? this.isDetecting,
      keywordToggles: keywordToggles ?? this.keywordToggles,
    );
  }
}