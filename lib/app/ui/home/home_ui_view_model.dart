// Notifier
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'home_ui_state.dart';

part 'home_ui_view_model.g.dart';



@riverpod
class HomeUiViewModel extends _$HomeUiViewModel {
  @override
  HomeUiState build() {
    return const HomeUiState(keywordToggles: [
      KeywordToggle(keyword: '合言葉1', isActive: true),
      KeywordToggle(keyword: '合言葉2', isActive: false),
      KeywordToggle(keyword: '合言葉3', isActive: true),
    ]);
  }

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
  /// 音声検知のON/OFFを切り替える
  void toggleDetection() {
    state = state.copyWith(isDetecting: !state.isDetecting);
  }

  /// キーワードを指定して、そのスイッチ状態を反転させる
  void toggleKeyword(String keyword) {
    final toggles = state.keywordToggles.map((toggle) {
      if (toggle.keyword == keyword) {
        return toggle.copyWith(isActive: !toggle.isActive);
      }
      return toggle;
    }).toList();

    state = state.copyWith(keywordToggles: toggles);
  }
}