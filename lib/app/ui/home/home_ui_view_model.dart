// Notifier
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'home_ui_state.dart';

part 'home_ui_view_model.g.dart';

@riverpod
class HomeUiViewModel extends _$HomeUiViewModel {
  @override
  HomeUiState build() {
    return const HomeUiState();
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