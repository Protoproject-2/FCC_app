// UI層の状態を保持するためのクラス。
// ON/OFF状態や、合言葉のON/OFFスイッチの状態を一括して管理する。
class HomeUiState {
  final bool isDetecting; // 音声検知がONかOFFかの状態
  final List<KeywordToggle> keywordToggles; // 各合言葉のスイッチ状態

  const HomeUiState({
    this.isDetecting = false,
    this.keywordToggles = const [
      KeywordToggle(keyword: '合言葉1', isActive: true),
      KeywordToggle(keyword: '合言葉2', isActive: false),
      KeywordToggle(keyword: '合言葉3', isActive: true),
    ],
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

// 合言葉1つ分のスイッチ状態を表すクラス。
// キーワード文字列と、それが有効かどうかのフラグを保持。
class KeywordToggle {
  final String keyword; // 合言葉文字列
  final bool isActive;  // この合言葉が有効かどうか

  const KeywordToggle({
    required this.keyword,
    required this.isActive,
  });

  // 個別のフィールドのみを更新した新しいインスタンスを返す。
  KeywordToggle copyWith({String? keyword, bool? isActive}) {
    return KeywordToggle(
      keyword: keyword ?? this.keyword,
      isActive: isActive ?? this.isActive,
    );
  }
}
